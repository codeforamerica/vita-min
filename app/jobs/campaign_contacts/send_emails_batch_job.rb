class CampaignContacts::SendEmailsBatchJob < ApplicationJob
  queue_as :campaign_mailer

  BATCH_SIZE = 500

  def perform(message_name, sent_at_column)
    now = Time.current

    ids = CampaignContact.email_contacts_for(sent_at_column).limit(BATCH_SIZE).pluck(:id)
    return if ids.empty?

    # claim to prevent concurrent tasks
    # todo: update this sent at logic??
    updated = CampaignContact.where(id: ids, sent_at_column => nil).update_all(sent_at_column => now, updated_at: now)
    return if updated.zero?

    CampaignContact.where(id: ids).find_each do |contact|
      CampaignEmail.create(
        campaign_contact_id: contact.id,
        message_name: message_name,
        to_email: contact.email_address,
      )
    end

    # queues up the next batch once this one is done
    self.class.perform_later(message_name, sent_at_column)
  end

  def priority
    PRIORITY_LOW
  end
end
