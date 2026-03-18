module Hub
  class MessagingDashboardController < Hub::BaseController
    layout "hub"
    before_action :require_admin

    def show
      @total = CampaignSms.count
      @succeeded = CampaignSms.succeeded.count
      @failed = CampaignSms.failed.count
      @in_progress = CampaignSms.in_progress.count
    end

    def chart_data
      render json: {
        status_breakdown: status_breakdown_data,
        messages_over_time: messages_over_time_data,
        failure_by_error: failure_by_error_data,
        status_by_message: status_by_message_data,
      }
    end

    private

    def status_breakdown_data
      CampaignSms.group(:twilio_status).count.transform_keys { |k| k.presence || "unknown" }
    end

    def messages_over_time_data
      rows = CampaignSms.where(created_at: 90.days.ago..)
                        .group("DATE(created_at)", :twilio_status).count

      dates = rows.keys.map(&:first).uniq.sort
      statuses = rows.keys.map(&:last).uniq

      datasets = statuses.map do |status|
        { label: status.presence || "unknown",
          data: dates.map { |d| rows[[d, status]] || 0 } }
      end

      { labels: dates.map(&:to_s), datasets: datasets }
    end

    def failure_by_error_data
      CampaignSms.where.not(error_code: [nil, ""]).group(:error_code)
                 .count.sort_by { |_, v| -v }.first(15).to_h
    end

    def status_by_message_data
      rows = CampaignSms.group(:message_name, :twilio_status).count

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