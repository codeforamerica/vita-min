# Do these things before running this job to prevent against throttling:
# 1. Check the number of messages you expect to run
# 2. Check if our IPs have been warmed up recently
# 3. Message MailGun Rep and tell them how many messages we are expecting to send and when?
# 4. Add appropriate delays and monitor MailGun logs to make sure messages aren't getting throttled
# 5. If messages are getting throttled, cancel either via hub/delayed_jobs select campaign_mailers queue and cancel jobs
# or by enabling flipper flag :cancel_campaign_emails

class CampaignContacts::SendEmailsBatchJob < ApplicationJob
  queue_as :campaign_mailer

  def perform(message_name, batch_size: 100, batch_delay: 1.minute, queue_next_batch: false)
    return if Flipper.enabled?(:cancel_campaign_emails)

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