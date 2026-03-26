# == Schema Information
#
# Table name: paused_email_domains
#
#  id           :bigint           not null, primary key
#  domain       :citext           not null
#  paused_until :datetime
#  reason       :string
#  created_at   :datetime         not null
#  updated_at   :datetime         not null
#
# Indexes
#
#  index_paused_email_domains_on_domain        (domain) UNIQUE
#  index_paused_email_domains_on_paused_until  (paused_until)
#
class PausedEmailDomain < ApplicationRecord
  scope :active, -> { where("paused_until IS NULL OR paused_until > ?", Time.current) }

  def self.paused?(domain)
    return false if domain.blank?
    active.exists?(domain: domain.downcase)
  end

  def self.pause!(domain, minutes: 60, reason: nil)
    upsert(
      {
        domain: domain.downcase,
        paused_until: Time.current + minutes.minutes,
        reason: reason,
        updated_at: Time.current,
        created_at: Time.current
      },
      unique_by: :index_paused_email_domains_on_domain
    )
  end
end
