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


  def perform(
    message_name,
    batch_size: 100,
    email_delay: 1.second,
    queue_next_batch: false,
    scope: nil
  )
    return if Flipper.enabled?(:cancel_campaign_emails)
    return unless CampaignMessage::CampaignMessage.valid_msg_name?(message_name)

    contacts_to_message = CampaignContact.for_email_scope(scope, message_name).limit(batch_size)
    return if contacts_to_message.empty?

    # determine buffer between last batch's messages and this batch's
    last_scheduled_for_message = CampaignEmail.where(message_name: message_name, sent_at: nil).maximum(:scheduled_send_at)
    start_time = if last_scheduled_for_message.present?
                   [(Time.current + 5.seconds), last_scheduled_for_message + email_delay].max
                 else
                   Time.current + 5.seconds
                 end

    max_scheduled_send_at = nil
    send_index = 0

    contacts_to_message.each do |contact|
      domain = CampaignEmail.domain_for(contact.email_address)
      next if PausedEmailDomain.paused?(domain)

      scheduled_send_at = start_time + (send_index * email_delay)

      email = CampaignEmail.create_or_find_for(
        contact: contact,
        message_name: message_name,
        scheduled_send_at: scheduled_send_at
      )

      next unless email.previously_new_record?

      max_scheduled_send_at = [max_scheduled_send_at, email.scheduled_send_at].compact.max

      send_index += 1
    end

    if queue_next_batch
      wait_seconds = if max_scheduled_send_at.present?
                       [(max_scheduled_send_at + 5.seconds) - Time.current, 0].max
                     else
                       5.seconds
                     end

      Campaign::SendEmailsBatchJob.set(wait: wait_seconds).perform_later(
        message_name: message_name, batch_size: batch_size, email_delay: email_delay,
        queue_next_batch: true, scope: scope
      )
    end
  end

  def priority
    PRIORITY_LOW
  end
end