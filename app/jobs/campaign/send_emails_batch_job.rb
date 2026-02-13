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

class Campaign::SendEmailsBatchJob < ApplicationJob
  queue_as :campaign_mailer
  include Campaign::Scheduling

  def perform(
    message_name,
    batch_size: 100,
    batch_delay: 1.minute,
    queue_next_batch: false,
    recent_signups_only: false
  )
    return if Flipper.enabled?(:cancel_campaign_emails)
    return if rate_limited?

    contacts_to_message = if recent_signups_only
                            CampaignContact.eligible_for_email_with_recent_signup(message_name).limit(batch_size).pluck(:id)
                          else
                            CampaignContact.eligible_for_email(message_name).limit(batch_size).pluck(:id)
                          end

    return if contacts_to_message.empty?

    puts "*****CAMPAIGN EMAILS: message_name=#{message_name} batch_size=#{contacts_to_message.count} recent_signups_only=#{recent_signups_only} queue_next_batch=#{queue_next_batch}*****" unless Rails.env.test?

    start_time = next_business_hour_start

    CampaignContact.where(id: contacts_to_message).find_each.with_index do |contact, index|
      # add delays between individual emails to prevent throttling
      scheduled_send_at = start_time + (index * 0.2).seconds

      CampaignEmail.create!(
        campaign_contact_id: contact.id,
        message_name: message_name,
        to_email: contact.email_address,
        scheduled_send_at: scheduled_send_at
      )
    rescue ActiveRecord::RecordNotUnique
      next # already claimed by another worker
    end

    if queue_next_batch
      Campaign::SendEmailsBatchJob.set(wait: batch_delay)
                                  .perform_later(message_name, batch_size: batch_size, batch_delay: batch_delay,
                                                               queue_next_batch: true, recent_signups_only: recent_signups_only)
    end
  end

  def priority
    PRIORITY_LOW
  end

  private

  def rate_limited?
    recent_emails = CampaignEmail.where("sent_at > ?", 1.hour.ago)

    total_count = recent_emails.count
    return false if total_count.zero?

    rate_limit_phrases = ["%rate limit%", "%ratelimit%"]

    rate_limited_count = recent_emails.where(
      "error_code = ? OR event_data::text ILIKE ANY(ARRAY[?])",
      "421",
      rate_limit_phrases
    ).count

    rate_limited_rate = ((rate_limited_count.to_f / total_count) * 100).round(1)

    if rate_limited_rate > 15
      Flipper.enable(:cancel_campaign_emails)
      Sentry.capture_message("Campaign Emails: Rate limiting detected: #{rate_limited_rate}% rate-limited. Pausing campaign emails. Disable :cancel_campaign_emails to start again.")
      return true
    end

    false
  end
end
