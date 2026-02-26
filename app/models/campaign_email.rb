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
#  idx_campaign_emails_on_domain                         (lower(split_part((to_email)::text, '@'::text, 2)))
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

  def self.create_or_find_for(contact:, message_name:, scheduled_send_at:)
    create!(
      campaign_contact_id: contact.id,
      message_name: message_name,
      to_email: contact.email_address,
      scheduled_send_at: scheduled_send_at
    )
  rescue ActiveRecord::RecordNotUnique
    find_by!(campaign_contact_id: contact.id, message_name: message_name)
  end

  def self.rate_limit_signal?(email)
    return true if email.error_code == "421"

    text = email.event_data.to_s.downcase
    text.include?("rate limit") || text.include?("ratelimit")
  end

  def self.domain_for(email)
    return nil if email.blank?

    domain = email.to_s.strip.downcase.split("@", 2).last
    return nil if domain.blank?

    domain
  end

  def self.rate_limited_for_domain?(domain, window: 20.minutes, threshold: 15, min_sample: 20, pause_for: 60.minutes)
    domain = domain.to_s.downcase.strip
    return false if domain.blank?

    return true if PausedEmailDomain.paused?(domain)

    recent_emails_with_domain = CampaignEmail.where("sent_at > ?", window.ago)
                                             .where("lower(split_part(to_email, '@', 2)) = ?", domain)

    total_email_count = recent_emails_with_domain.count
    return false if total_email_count < min_sample

    rate_limit_phrases = ["%rate limit%", "%ratelimit%"]
    rate_limited = recent_emails_with_domain.where(
      "error_code = ? OR event_data::text ILIKE ANY(ARRAY[?])",
      "421",
      rate_limit_phrases
    ).count

    rate = ((rate_limited.to_f / total_email_count) * 100).round(1)

    if rate > threshold
      PausedEmailDomain.pause!(
        domain,
        minutes: (pause_for / 60).to_i,
        reason: "Rate limiting: #{rate}% (#{rate_limited}/#{total_email_count}) in last #{window.inspect}"
      )

      Sentry.capture_message(
        "Campaign Emails: Domain throttling detected for #{domain}: #{rate}% " \
          "(#{rate_limited}/#{total_email_count}) over last #{window.inspect}. Pausing for #{pause_for.inspect}."
      )

      return true
    end

    false
  end

  private

  def deliver
    if scheduled_send_at.blank? || Time.current >= scheduled_send_at
      Campaign::SendCampaignEmailJob.perform_later(id)
    else
      Campaign::SendCampaignEmailJob.set(wait_until: scheduled_send_at).perform_later(id)
    end
  end
end
