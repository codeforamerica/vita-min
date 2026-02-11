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

  def self.status_column
    :twilio_status
  end

  belongs_to :campaign_contact
  after_create :deliver

  validates :twilio_status, inclusion: { in: TwilioService::ALL_KNOWN_STATUSES }
  scope :succeeded, -> { where(twilio_status: TwilioService::SUCCESSFUL_STATUSES) }
  scope :failed, -> { where(twilio_status: TwilioService::FAILED_STATUSES) }
  scope :in_progress, -> { where(twilio_status: TwilioService::IN_PROGRESS_STATUSES) }

  private

  def deliver
    if scheduled_send_at.blank? || Time.current >= scheduled_send_at
      Campaign::SendCampaignSmsJob.perform_later(id)
    else
      Campaign::SendCampaignSmsJob.set(wait_until: scheduled_send_at).perform_later(id)
    end
  end
end
