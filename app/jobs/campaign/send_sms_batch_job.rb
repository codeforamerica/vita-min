# Do these things before running this job to prevent against throttling:
#   1. Check the number of messages you expect to run
#   2. Add appropriate delays and monitor Twilio logs to make sure messages aren't getting throttled
#       can also monitor datadog messaging dashboard and /messaging_dashboard page
#   3. If messages are getting throttled and not getting caught by the 'rate_limited?' check,
#      then you can kill the jobs by enabling the :cancel_campaign_sms flipper flag manually

class Campaign::SendSmsBatchJob < ApplicationJob
  queue_as :campaign_sms
  include Campaign::Scheduling

  # the minimum schedule in the distance time for Twilio is 15min
  # which means the time between batches will be 15min at least
  # which necessitates larger batch sizes to get through the load
  def perform(message_name: nil,
              batch_size: 1000,
              msg_delay: 1.second,
              queue_next_batch: false,
              scope: nil)

    raise ArgumentError, "'#{message_name}' message_name is required" if message_name.nil?
    raise ArgumentError, "'#{message_name}' message has no sms body" unless message(message_name)&.sms_body(contact: nil).present?

    return if Flipper.enabled?(:cancel_campaign_sms)
    return if rate_limited?

    contacts_to_message = CampaignContact.for_sms_scope(scope, message_name).limit(batch_size)

    return if contacts_to_message.empty?

    msg_start_time = message_start_time(message_name: message_name, msg_delay: msg_delay)
    max_scheduled_send_at = nil
    send_index = 0

    contacts_to_message.each do |contact|
      # add delays between sms-messages to prevent throttling,
      # eventually we can get rid of this and use Twilio's traffic shaping feature when its out of beta
      scheduled_send_at = msg_start_time + (send_index * msg_delay)

      sms = CampaignSms.create_or_find_for(
        contact: contact,
        message_name: message_name,
        scheduled_send_at: scheduled_send_at
      )

      next unless sms.previously_new_record?

      max_scheduled_send_at = [max_scheduled_send_at, scheduled_send_at].compact.max
      send_index += 1
    end

    if queue_next_batch
      Campaign::SendSmsBatchJob.set(wait: batch_buffer(max_scheduled_send_at))
                               .perform_later(
                                 message_name: message_name, batch_size: batch_size,
                                 msg_delay: msg_delay, queue_next_batch: true,
                                 scope: scope
                               )
    end
  end

  def priority
    PRIORITY_LOW
  end

  private

  def message_start_time(message_name:, msg_delay:)
    twilio_scheduled_sent_at_minimum = 15.minutes + 30.seconds # minimum for Twilio API is 15min plus buffer between here and calling the Twilio API
    last_scheduled_for_message = CampaignSms.where(message_name: message_name, sent_at: nil).maximum(:scheduled_send_at)
    if last_scheduled_for_message.present?
      [(Time.current + twilio_scheduled_sent_at_minimum), last_scheduled_for_message + msg_delay].max
    else
      Time.current + twilio_scheduled_sent_at_minimum
    end
  end

  def batch_buffer(max_scheduled_send_at)
    # buffer for the actual batch job
    if max_scheduled_send_at.present?
      [(max_scheduled_send_at + 5.seconds) - Time.current, 0].max
    else
      5.seconds
    end
  end

  def message(message_name)
    klass = "CampaignMessage::#{message_name.camelize}".safe_constantize
    raise ArgumentError, "Unknown message_name: #{message_name}" unless klass
    klass.new
  end

  def rate_limited?
    recent_texts = CampaignSms.where("sent_at > ?", 1.hour.ago)
    total_count = recent_texts.count
    return false if total_count.zero?

    rate_limit_codes = ["63038", "20429", "30001", "14107", "25021"]
    rate_limit_phrases = ["%message rate exceeded%", "%too many requests%", "%queue overflow%"]

    rate_limited_count = recent_texts.where(
      "error_code IN (?) OR event_data::text ILIKE ANY(ARRAY[?])",
      rate_limit_codes,
      rate_limit_phrases
    ).count

    failure_rate = ((rate_limited_count.to_f / total_count) * 100).round(1)

    if failure_rate > 15
      Flipper.enable(:cancel_campaign_sms)
      Sentry.capture_message(
        "Campaign Text Messages: Rate limiting detected: #{failure_rate}% rate-limited. Pausing campaign text messages. Disable :cancel_campaign_sms to start again."
      )
      return true
    end

    false
  end
end