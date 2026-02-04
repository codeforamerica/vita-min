# == Schema Information
#
# Table name: outgoing_campaign_emails
#
#  id                  :bigint           not null, primary key
#  delivery_status     :string           default("created"), not null
#  error_code          :string
#  event_data          :jsonb
#  from_email          :string
#  message_name        :string
#  sent_at             :datetime
#  subject             :text
#  to_email            :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  campaign_contact_id :bigint           not null
#  mailgun_message_id  :string
#
# Indexes
#
#  index_outgoing_campaign_emails_on_campaign_contact_id  (campaign_contact_id)
#  index_outgoing_campaign_emails_on_mailgun_message_id   (mailgun_message_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (campaign_contact_id => campaign_contacts.id)
#
class OutgoingCampaignEmail < ApplicationRecord
  # todo: add locale?
  belongs_to :campaign_contact
  after_create :deliver

  # delivery_status => created/queued/accepted/delivered/failed_temp/failed_perm/complained/etc

  private

  def deliver
    CampaignContacts::SendCampaignEmailJob.perform_later(id)
  end
end
