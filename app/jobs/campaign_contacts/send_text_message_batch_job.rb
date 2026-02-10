# Do these things before running this job to prevent against throttling:
#   1. Check the number of messages you expect to run
#   2. Add appropriate delays and monitor Twilio logs to make sure messages aren't getting throttled
#      (signs of throttling include ....)
#   3. If messages are getting throttled and not getting caught by the 'rate_limited?' check,
#      then you can kill the jobs by enabling the :cancel_campaign_sms flipper flag manually

class CampaignContacts::SendTextMessageBatchJob < ApplicationJob
  queue_as :campaign_sms

  def perform(message_name, batch_size: 100, batch_delay: 1.minute, queue_next_batch: false, recent_signups_only: false)
    return if Flipper.enabled?(:cancel_campaign_sms)
    return if rate_limited?

    contacts_to_message = if recent_signups_only
                            CampaignContact.eligible_for_text_message_with_recent_signup(message_name).limit(batch_size).pluck(:id)
                          else
                            CampaignContact.eligible_for_text_message(message_name).limit(batch_size).pluck(:id)
                          end

    puts "*********************MESSAGING: #{contacts_to_message.count}"
    return if contacts_to_message.empty?

    klass = "CampaignMessage::#{message_name.camelize}".safe_constantize
    raise ArgumentError, "Unknown message_name: #{message_name}" unless klass
    message = klass.new

    start_time = next_business_hour_start

    index = 0
    CampaignContact.where(id: contacts_to_message).find_each do |contact|
      # add delays between sms-messages to prevent throttling
      scheduled_send_at = start_time + (index * 0.2).seconds

      CampaignTextMessage.create!(
        campaign_contact_id: contact.id,
        message_name: message_name,
        body: message.sms_body(locale: contact.locale), # need to pass this in where we can find locale,
        to_phone_number: contact.sms_phone_number,
        scheduled_send_at: scheduled_send_at
      )
      index += 1
    rescue ActiveRecord::RecordNotUnique
      next # already claimed by another worker
    end

    if queue_next_batch
      CampaignContacts::SendTextMessageBatchJob.set(wait: batch_delay)
          .perform_later(message_name, batch_size: batch_size, batch_delay: batch_delay)
    end
  end

  def priority
    PRIORITY_LOW
  end

  private

  def rate_limited?
    failed_texts = CampaignTextMessage.where("sent_at > ?", 1.hour.ago)
                                      .where(twilio_status: %w[failed undelivered])

    return false if failed_texts.empty?

    rate_limit_codes = [63038, 20429, 30001]
    rate_limit_phrases = [
      "%Message rate exceeded%",
      "%Too many requests%",
      "%Queue overflow%"
    ]

    rate_limited_count = failed_texts.where(
      "error_code IN (?) OR event_data::text ILIKE ANY(ARRAY[?])",
      rate_limit_codes,
      rate_limit_phrases
    ).count

    failure_rate = (rate_limited_count.to_f / total_count * 100)

    if failure_rate > 15
      Flipper.enable(:cancel_campaign_emails)
      Sentry.capture_exception("CAMPAIGN TEXT MESSAGES: Rate limiting detected: #{failure_rate}% failure rate. Pausing campaigns text messages. Disable :cancel_campaign_sms to start again.")
      return true
    end

    false
  end

  def next_business_hour_start
    now = Time.current.in_time_zone("America/New_York")

    # within business hours (8am-9pm) => start now
    if now.hour >= 8 && now.hour < 21
      return Time.current
    end

    # before 8am => schedule for 8am same day
    if now.hour < 8
      return now.change(hour: 8, min: 0, sec: 0).in_time_zone('UTC')
    end

    # after 9pm => schedule for 8am next day
    (now + 1.day).change(hour: 8, min: 0, sec: 0).in_time_zone('UTC')
  end
end