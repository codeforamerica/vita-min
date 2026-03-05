# == Schema Information
#
# Table name: diy_intakes
#
#  id                        :bigint           not null, primary key
#  clicked_chat_with_us_at   :datetime
#  email_address             :string
#  email_notification_opt_in :integer          default("unfilled")
#  filing_frequency          :integer          default("unfilled")
#  locale                    :string
#  preferred_first_name      :string
#  received_1099             :integer          default("unfilled"), not null
#  referrer                  :string
#  sms_notification_opt_in   :integer          default("unfilled")
#  sms_phone_number          :string
#  source                    :string
#  state_of_residence        :string
#  token                     :string
#  zip_code                  :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  visitor_id                :string
#
class DiyIntake < ApplicationRecord
  attr_accessor :email_address_confirmation

  enum received_1099: { unfilled: 0, yes: 1, no: 2 }, _prefix: :received_1099
  enum filing_frequency: { unfilled: 0, every_year: 1, some_years: 2, not_filed: 3 }, _prefix: :filing_frequency
  enum email_notification_opt_in: { unfilled: 0, yes: 1, no: 2 }, _prefix: :email_notification_opt_in
  enum sms_notification_opt_in: { unfilled: 0, yes: 1, no: 2 }, _prefix: :sms_notification_opt_in

  has_secure_token :token

  validates :email_address, 'valid_email_2/email': { mx: true }, confirmation: true

  scope :sms_contactable, lambda {
    where.not(sms_phone_number: [nil, ""])
         .where(sms_notification_opt_in: sms_notification_opt_ins[:yes])
  }
  scope :email_contactable, lambda {
    where.not(email_address: [nil, ""])
         .where(email_notification_opt_in: email_notification_opt_ins[:yes])
  }
  scope :contactable, -> { sms_contactable.or(email_contactable) }

  def self.should_carry_over_params_from?(intake)
    intake && intake.updated_at > 30.minutes.ago && intake.preferred_name.present? && intake.triage_filing_frequency.present?
  end

  def campaign_contact
    CampaignContact.where("? = ANY(diy_intake_ids)", id).first
  end

  def create_or_update_campaign_contact
    return if email_address.blank? && sms_phone_number.blank?

    Campaign::UpsertSourceIntoCampaignContacts.call(
      source: :diy,
      source_id: id,
      first_name: preferred_first_name,
      last_name: nil,
      email: email_address,
      phone: sms_phone_number,
      email_opt_in: email_notification_opt_in == "yes",
      sms_opt_in: sms_notification_opt_in == "yes",
      locale: locale,
      latest_diy_intake_at: created_at,
      backfill: false
      )
  end
end
