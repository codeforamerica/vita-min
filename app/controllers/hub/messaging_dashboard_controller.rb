module Hub
  class MessagingDashboardController < Hub::BaseController
    layout "hub"
    before_action :require_admin

    def show; end

    def chart_data
      render json: {
        kpis: {
          total: scoped_sms.count,
          succeeded: scoped_sms.succeeded.count,
          failed: scoped_sms.failed.count,
          in_progress: scoped_sms.in_progress.count,
        },
        status_breakdown: status_breakdown_data,
        messages_over_time: messages_over_time_data,
        failure_by_error: failure_by_error_data,
        status_by_message: status_by_message_data,
      }
    end

    private

    def time_range_start
      case params[:range]
      when "5min" then 5.minutes.ago
      when "10min" then 10.minutes.ago
      when "30min" then 30.minutes.ago
      when "1h" then 1.hour.ago
      when "2h" then 2.hours.ago
      when "4h" then 4.hours.ago
      when "1d" then 1.day.ago
      when "7d" then 7.days.ago
      when "2w" then 2.weeks.ago
      when "1m" then 1.month.ago
      when "2m" then 2.months.ago
      when "3m" then 3.months.ago
      when "all" then nil
      end
    end

    def time_group
      case params[:range]
      when "1h", "2h", "4h" then "DATE_TRUNC('hour', created_at)"
      when "1d" then "DATE_TRUNC('hour', created_at)"
      else "DATE(created_at)"
      end
    end

    def scoped_sms
      @scoped_sms ||= if time_range_start.nil?
                        CampaignSms.all
                      else
                        CampaignSms.where(created_at: time_range_start..)
                      end
    end

    def status_breakdown_data
      scoped_sms.group(:twilio_status).count
                .transform_keys { |k| k.presence || "unknown" }
    end

    def messages_over_time_data
      rows = scoped_sms
               .group(time_group, :twilio_status)
               .count

      dates = rows.keys.map(&:first).uniq.sort
      statuses = rows.keys.map(&:last).uniq

      datasets = statuses.map do |status|
        { label: status.presence || "unknown",
          data: dates.map { |d| rows[[d, status]] || 0 } }
      end

      { labels: dates.map(&:to_s), datasets: datasets }
    end

    def failure_by_error_data
      scoped_sms
        .where.not(error_code: [nil, ""])
        .group(:error_code)
        .count
        .sort_by { |_, v| -v }
        .first(15)
        .to_h
    end

    def status_by_message_data
      rows = scoped_sms.group(:message_name, :twilio_status).count

      message_names = rows.keys.map(&:first).uniq.sort
      statuses = rows.keys.map(&:last).uniq

      datasets = statuses.map do |status|
        { label: status.presence || "unknown",
          data: message_names.map { |m| rows[[m, status]] || 0 } }
      end

      { labels: message_names, datasets: datasets }
    end
  end
end