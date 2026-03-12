# == Schema Information
#
# Table name: campaign_sms
#
#  id                  :bigint           not null, primary key
#  body                :text             not null
#  error_code          :string
#  event_data          :jsonb
#  message_name        :string           not null
#  scheduled_send_at   :datetime
#  sent_at             :datetime
#  to_phone_number     :string           not null
#  twilio_sid          :string
#  twilio_status       :string
#  created_at          :datetime         not null
#  updated_at          :datetime         not null
#  campaign_contact_id :bigint           not null
#
# Indexes
#
#  index_campaign_sms_on_campaign_contact_id               (campaign_contact_id)
#  index_campaign_sms_on_message_name_and_to_phone_number  (message_name,to_phone_number) UNIQUE
#  index_campaign_sms_on_twilio_sid                        (twilio_sid) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (campaign_contact_id => campaign_contacts.id)
#
class CampaignSms < ApplicationRecord
  include RecordsTwilioStatus
  belongs_to :campaign_contact

  def self.status_column
    :twilio_status
  end

  belongs_to :campaign_contact
  after_create :deliver

  validates :twilio_status, inclusion: { in: TwilioService::ALL_KNOWN_STATUSES }
  scope :succeeded, -> { where(twilio_status: TwilioService::SUCCESSFUL_STATUSES) }
  scope :failed, -> { where(twilio_status: TwilioService::FAILED_STATUSES) }
  scope :in_progress, -> { where(twilio_status: TwilioService::IN_PROGRESS_STATUSES) }

  def self.create_or_find_for(contact:, message_name:, scheduled_send_at:)
    message_body = "CampaignMessage::#{message_name.camelize}".safe_constantize&.new&.sms_body(contact: contact)
    return unless message_body

    create!(
      campaign_contact_id: contact.id,
      message_name: message_name,
      to_phone_number: contact.sms_phone_number,
      body: message_body,
      scheduled_send_at: scheduled_send_at
    )
  rescue ActiveRecord::RecordNotUnique
    find_by!(to_phone_number: to_phone_number, message_name: message_name)
  end

  private

  def deliver
    Campaign::SendCampaignSmsJob.perform_later(id)
  end
end
