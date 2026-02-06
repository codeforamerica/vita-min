# == Schema Information
#
# Table name: campaign_contacts
#
#  id                              :bigint           not null, primary key
#  email_address                   :citext
#  email_notification_opt_in       :boolean          default(FALSE)
#  first_name                      :string
#  gyr_intake_ids                  :bigint           default([]), is an Array
#  last_name                       :string
#  locale                          :string
#  sign_up_ids                     :bigint           default([]), is an Array
#  sms_notification_opt_in         :boolean          default(FALSE)
#  sms_phone_number                :string
#  state_file_intake_refs          :jsonb            not null
#  suppressed_for_gyr_product_year :integer
#  created_at                      :datetime         not null
#  updated_at                      :datetime         not null
#
# Indexes
#
#  index_campaign_contacts_on_email_address              (email_address) UNIQUE WHERE (email_address IS NOT NULL)
#  index_campaign_contacts_on_email_notification_opt_in  (email_notification_opt_in)
#  index_campaign_contacts_on_first_name_and_last_name   (first_name,last_name)
#  index_campaign_contacts_on_gyr_intake_ids             (gyr_intake_ids) USING gin
#  index_campaign_contacts_on_gyr_suppression            (suppressed_for_gyr_product_year)
#  index_campaign_contacts_on_sign_up_ids                (sign_up_ids) USING gin
#  index_campaign_contacts_on_sms_notification_opt_in    (sms_notification_opt_in)
#  index_campaign_contacts_on_sms_phone_number           (sms_phone_number)
#  index_campaign_contacts_on_state_file_intake_refs     (state_file_intake_refs) USING gin
#
class CampaignContact < ApplicationRecord
  validates :sms_phone_number, e164_phone: true, allow_blank: true
  validates :email_address, 'valid_email_2/email': true, allow_blank: true
  has_many :campaign_emails
  has_many :signups, -> { where("signups.id = ANY(campaign_contacts.sign_up_ids)") },
           class_name: "Signup"

  def self.with_signups_from_recent_off_season
    joins(:signups).where("signups.created_at >= ?", 1.year.ago).distinct
  end

  # Email -------------
  def self.not_emailed(message_name)
    where.not(id: CampaignEmail.where(message_name: message_name).select(:campaign_contact_id))
  end

  def self.emailed(message_name)
    where(id: CampaignEmail.where(message_name: message_name).select(:campaign_contact_id))
  end

  def self.emailed_successfully(message_name)
    where(id: CampaignEmail.succeeded.where(message_name: message_name).select(:campaign_contact_id))
  end

  def self.email_contacts_opted_in
    where(email_notification_opt_in: true).where.not(email_address: [nil, ""])
  end

  # SMS -------------
  def self.sms_contacts_for(sent_at_column)
    where(sent_at_column => nil, sms_notification_opt_in: true)
      .where.not(sms_phone_number: nil)
  end

  def self.sms_unique_phone_count(sent_at_column)
    sms_contacts_for(sent_at_column).distinct.count(:sms_phone_number)
  end
end
