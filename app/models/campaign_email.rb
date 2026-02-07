# == Schema Information
#
# Table name: campaign_emails
#
#  id                  :bigint           not null, primary key
#  error_code          :string
#  event_data          :jsonb
#  from_email          :string
#  mailgun_status      :string           default("created"), not null
#  message_name        :string
#  scheduled_send_at   :datetime
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
#  index_campaign_emails_on_campaign_contact_id          (campaign_contact_id)
#  index_campaign_emails_on_contact_id_and_message_name  (campaign_contact_id,message_name) UNIQUE
#  index_campaign_emails_on_mailgun_message_id           (mailgun_message_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (campaign_contact_id => campaign_contacts.id)
#
class CampaignEmail < ApplicationRecord
  belongs_to :campaign_contact
  after_create :deliver

  # Include only statuses we have webhooks configured for in MailGun
  FAILED_MAILGUN_STATUSES = ["permanent_fail", "failed"].freeze
  SUCCESSFUL_MAILGUN_STATUSES = ["delivered", "opened"].freeze
  IN_PROGRESS_MAILGUN_STATUSES = ["sending", "created"].freeze
  ALL_KNOWN_MAILGUN_STATUSES = FAILED_MAILGUN_STATUSES + SUCCESSFUL_MAILGUN_STATUSES + IN_PROGRESS_MAILGUN_STATUSES
  validates :mailgun_status, inclusion: { in: ALL_KNOWN_MAILGUN_STATUSES }

  scope :succeeded, -> { where(mailgun_status: SUCCESSFUL_MAILGUN_STATUSES) }
  scope :failed, -> { where(mailgun_status: FAILED_MAILGUN_STATUSES) }
  scope :in_progress, -> { where(mailgun_status: IN_PROGRESS_MAILGUN_STATUSES) }

  private

  def deliver
    if scheduled_send_at.blank? || Time.current >= scheduled_send_at
      CampaignContacts::SendCampaignEmailJob.perform_later(id)
    else
      CampaignContacts::SendCampaignEmailJob.set(wait_until: scheduled_send_at).perform_later(id)
    end
  end
end
