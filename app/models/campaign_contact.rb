# == Schema Information
#
# Table name: campaign_contacts
#
#  id                        :bigint           not null, primary key
#  email_address             :citext
#  email_notification_opt_in :boolean          default(FALSE)
#  first_name                :string
#  gyr_intake_ids            :bigint           default([]), is an Array
#  last_name                 :string
#  latest_gyr_intake_at      :datetime
#  latest_signup_at          :datetime
#  locale                    :string
#  sign_up_ids               :bigint           default([]), is an Array
#  sms_notification_opt_in   :boolean          default(FALSE)
#  sms_phone_number          :string
#  state_file_intake_refs    :jsonb            not null
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#
# Indexes
#
#  index_campaign_contacts_on_email_address              (email_address) UNIQUE WHERE (email_address IS NOT NULL)
#  index_campaign_contacts_on_email_notification_opt_in  (email_notification_opt_in)
#  index_campaign_contacts_on_first_name_and_last_name   (first_name,last_name)
#  index_campaign_contacts_on_gyr_intake_ids             (gyr_intake_ids) USING gin
#  index_campaign_contacts_on_gyr_suppression            (suppressed_for_gyr_product_year)
#  index_campaign_contacts_on_latest_gyr_intake_at       (latest_gyr_intake_at)
#  index_campaign_contacts_on_latest_signup_at           (latest_signup_at)
#  index_campaign_contacts_on_sign_up_ids                (sign_up_ids) USING gin
#  index_campaign_contacts_on_sms_notification_opt_in    (sms_notification_opt_in)
#  index_campaign_contacts_on_sms_phone_number           (sms_phone_number)
#  index_campaign_contacts_on_state_file_intake_refs     (state_file_intake_refs) USING gin
#
class CampaignContact < ApplicationRecord
  self.ignored_columns = [:suppressed_for_gyr_product_year]
  validates :sms_phone_number, e164_phone: true, allow_blank: true
  validates :email_address, 'valid_email_2/email': true, allow_blank: true
  has_many :campaign_emails
  has_many :signups, -> { where("signups.id = ANY(campaign_contacts.sign_up_ids)") },
           class_name: "Signup"
  
  def self.with_signups_from_recent_off_season
    joins(:signups).where("signups.created_at >= ?", 1.year.ago).distinct
  end

  # Email -------------
  def self.eligible_for_email(message_name)
    emailed_contact_ids = CampaignEmail.where(message_name: message_name).select(:campaign_contact_id)

    where(email_notification_opt_in: true).where.not(email_address: [nil, ""]) # opted-in
      .where.not(id: emailed_contact_ids) # hasn't been sent this message before
      .where("latest_gyr_intake_at IS NULL OR latest_gyr_intake_at <= ?", gyr_intake_cutoff) # hasn't started an intake this year yet
  end

  def self.eligible_for_email_with_recent_signup(message_name)
    eligible_for_email(message_name).where("latest_signup_at >= ?", signup_cutoff)
  end

  # SMS -------------
  def self.eligible_for_text_message(message_name)
    already_messaged_phones = CampaignSms.where(message_name: message_name).select(:to_phone_number)

    where(sms_notification_opt_in: true).where.not(sms_phone_number: [nil, ""]) # opted-in
      .where("latest_gyr_intake_at IS NULL OR latest_gyr_intake_at <= ?", gyr_intake_cutoff) # hasn't started an intake this year yet
      .where.not(sms_phone_number: already_messaged_phones)
  end

  def self.eligible_for_text_message_with_recent_signup(message_name)
    # contacts with signups that were created from the end of the last filing season onward
    eligible_for_text_message(message_name).where("latest_signup_at >= ?", signup_cutoff)
  end

  private

  def self.signup_cutoff
    year = MultiTenantService.new(:gyr).current_tax_year - 1
    Rails.configuration.tax_year_filing_seasons[year].last
  end

  def self.gyr_intake_cutoff
    Rails.configuration.start_of_unique_links_only_intak
  end
end
