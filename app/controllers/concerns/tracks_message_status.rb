module TracksMessageStatus
  extend ActiveSupport::Concern

  private

  def track_message_status(metric_name, record, status, extra_tags: [])
    record_type = record&.class&.name&.underscore || "unknown"
    message_name = record&.respond_to?(:message_name) ? record.message_name : "n/a"

    DatadogApi.increment(metric_name, tags: %W[
      status:#{status}
      record_type:#{record_type}
      message_name:#{message_name}
    ] + extra_tags)
  end

  def track_missing_record(metric_name)
    DatadogApi.increment(metric_name)
  end
end