# == Schema Information
#
# Table name: idme_users
#
#  id                        :bigint           not null, primary key
#  birth_date                :string
#  city                      :string
#  consented_to_service      :integer          default("unfilled"), not null
#  consented_to_service_at   :datetime
#  consented_to_service_ip   :string
#  current_sign_in_at        :datetime
#  current_sign_in_ip        :inet
#  email                     :string
#  email_notification_opt_in :integer          default("unfilled"), not null
#  encrypted_ssn             :string
#  encrypted_ssn_iv          :string
#  first_name                :string
#  is_spouse                 :boolean          default(FALSE)
#  last_name                 :string
#  last_sign_in_at           :datetime
#  last_sign_in_ip           :inet
#  phone_number              :string
#  provider                  :string
#  sign_in_count             :integer          default(0), not null
#  sms_notification_opt_in   :integer          default("unfilled"), not null
#  state                     :string
#  street_address            :string
#  uid                       :string
#  zip_code                  :string
#  created_at                :datetime         not null
#  updated_at                :datetime         not null
#  intake_id                 :bigint           not null
#
# Indexes
#
#  index_idme_users_on_intake_id  (intake_id)
#
# Foreign Keys
#
#  fk_rails_...  (intake_id => intakes.id)
#

class IdmeUser < ApplicationRecord
  belongs_to :intake

  attr_encrypted :ssn, key: ->(_) { EnvironmentCredentials.dig(:db_encryption_key) }

  enum sms_notification_opt_in: { unfilled: 0, yes: 1, no: 2 }, _prefix: :sms_notification_opt_in
  enum email_notification_opt_in: { unfilled: 0, yes: 1, no: 2 }, _prefix: :email_notification_opt_in
  enum consented_to_service: { unfilled: 0, yes: 1, no: 2 }, _prefix: :consented_to_service

  def contact_info_filtered_by_preferences
    contact_info = {}
    contact_info[:phone_number] = standardized_phone_number if sms_notification_opt_in_yes?
    contact_info[:email] = email if email_notification_opt_in_yes?
    contact_info
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def parsed_birth_date
    Date.strptime(birth_date, "%Y-%m-%d")
  end

  # Returns the phone number in the E164 standardized format, e.g.: "+15105551234"
  def standardized_phone_number
    PhoneParser.normalize(phone_number)
  end

  # Returns the phone number formatted for user display, e.g.: "(510) 555-1234"
  def formatted_phone_number
    Phonelib.parse(phone_number).local_number
  end

  def formatted_ssn
    "#{ssn[0..2]}-#{ssn[3..4]}-#{ssn[5..-1]}" if ssn.present?
  end

  def ssn_last_four
    ssn.last(4)
  end

  def opted_into_notifications?
    sms_notification_opt_in_yes? || email_notification_opt_in_yes?
  end

  def age_end_of_tax_year
    return unless birth_date.present?

    intake.tax_year - Date.parse(birth_date).year
  end
end
