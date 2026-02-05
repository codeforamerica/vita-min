class CampaignContacts::SendEmailsBatchJob < ApplicationJob
  queue_as :campaign_mailer

  # Do these things before running this job to prevent against throttling:
  # 1. Check the number of messages you expect to run
  # 2. Check if our IPs have been warmed up recently
  # 3. Message MailGun Representative and tell them how many messages we are expecting to send and when?
  # 4. Add appropriate delays and monitor MailGun logs to make sure messages aren't getting throttled
  # 5. If messages are getting throttled, cancel either via delayed_jobs select campaign_mailers and cancel jobs
  # or by enabling flipper flag CANCEL_CAMPAIGN_EMAIL_JOBS

  def perform(message_name, batch_size: 100)
    ids = CampaignContact.email_contacts_opted_in
                         .not_emailed(message_name).limit(batch_size).pluck(:id)
    return if ids.empty?

    CampaignContact.where(id: ids).find_each do |contact|
      CampaignEmail.create!(
        campaign_contact_id: contact.id,
        message_name: message_name,
        to_email: contact.email_address,
      )
    rescue ActiveRecord::RecordNotUnique
      next # already claimed by another worker
    end

    # queues up the next batch once this one is done
    # todo: add delay and check if batch is paused/canceled or if there are alot of failures
    # status code 421, status message contains "rate limited" => for gmail servers
    self.class.perform_later(message_name)
  end

  def priority
    PRIORITY_LOW
  end
end