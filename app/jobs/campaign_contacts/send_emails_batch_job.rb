# Do these things before running this job to prevent against throttling:
#   1. Check the number of messages you expect to run
#   2. Check if our IPs have been warmed up recently
#   3. Message MailGun Rep and tell them how many messages we are expecting to send, when and over what period of time
#   4. Add appropriate delays and monitor MailGun logs to make sure messages aren't getting throttled
#      (signs of throttling include lots of temporary failures (status = "failed"),
#       mentions of getting "rate limit"ed in the mailgun reason or delivery-message,
#       or error codes of 421, although across different servers the error codes could be different)
#   5. If messages are getting throttled and not getting caught by the 'rate_limited?' check,
#      then you can kill the jobs by enabling the :cancel_campaign_emails flipper flag manually

class CampaignContacts::SendEmailsBatchJob < ApplicationJob
  queue_as :campaign_mailer

  def perform(message_name, batch_size: 100, batch_delay: 1.minute, queue_next_batch: false)
    return if Flipper.enabled?(:cancel_campaign_emails)
    return if rate_limited?

    contacts_to_message = CampaignContact.email_contacts_opted_in
                         .not_emailed(message_name).limit(batch_size).pluck(:id)

    return if contacts_to_message.empty?

    start_time = next_business_hour_start

    index = 0
    CampaignContact.where(id: contacts_to_message).find_each do |contact|
      # add delays between emails to prevent throttling
      scheduled_send_at = start_time + (index * 0.2).seconds

      CampaignEmail.create!(
        campaign_contact_id: contact.id,
        message_name: message_name,
        to_email: contact.email_address,
        scheduled_send_at: scheduled_send_at
      )
      index += 1
    rescue ActiveRecord::RecordNotUnique
      next # already claimed by another worker
    end

    if queue_next_batch
      CampaignContacts::SendEmailsBatchJob.set(wait: batch_delay)
          .perform_later(message_name, batch_size: batch_size, batch_delay: batch_delay)
    end
  end

  def priority
    PRIORITY_LOW
  end

  private

  def rate_limited?
    failed_emails = CampaignEmail.where("sent_at > ?", 1.hour.ago)
                                 .where(mailgun_status: "failed")

    return false if failed_emails.empty?

    total_count = failed_emails.count
    rate_limited_count = failed_emails.where(
      "error_code = ? OR event_data::text ILIKE ANY(ARRAY[?, ?])",
      "421",
      "%rate limit%",
      "%ratelimit%"
    ).count

    failure_rate = (rate_limited_count.to_f / total_count * 100)

    if failure_rate > 15
      Flipper.enable(:cancel_campaign_emails)
      Sentry.capture_exception("Rate limiting detected: #{failure_rate}% failure rate. Pausing campaigns.")
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