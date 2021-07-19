# == Schema Information
#
# Table name: dependents
#
#  id                      :bigint           not null, primary key
#  birth_date              :date
#  disabled                :integer          default("unfilled"), not null
#  encrypted_ip_pin        :string
#  encrypted_ip_pin_iv     :string
#  encrypted_ssn           :string
#  encrypted_ssn_iv        :string
#  first_name              :string
#  last_name               :string
#  months_in_home          :integer
#  north_american_resident :integer          default("unfilled"), not null
#  on_visa                 :integer          default("unfilled"), not null
#  relationship            :string
#  tin_type                :integer
#  was_married             :integer          default("unfilled"), not null
#  was_student             :integer          default("unfilled"), not null
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  intake_id               :bigint           not null
#
# Indexes
#
#  index_dependents_on_intake_id  (intake_id)
#

class Dependent < ApplicationRecord
  belongs_to :intake, inverse_of: :dependents

  attr_encrypted :ssn, key: ->(_) { EnvironmentCredentials.dig(:db_encryption_key) }
  attr_encrypted :ip_pin, key: ->(_) { EnvironmentCredentials.dig(:db_encryption_key) }

  enum was_student: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :was_student
  enum on_visa: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :on_visa
  enum north_american_resident: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :north_american_resident
  enum disabled: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :disabled
  enum was_married: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :was_married
  enum tin_type: { ssn: 0, itin: 1, none: 2 }, _prefix: :tin_type

  validates_presence_of :first_name
  validates_presence_of :last_name
  validates_presence_of :birth_date
  validates_presence_of :relationship, if: -> { intake&.is_ctc? }

  validates_presence_of :ssn, if: -> { intake&.is_ctc? }
  validates_confirmation_of :ssn, if: -> { ssn.present? && ssn_changed? }
  validates :ssn, social_security_number: true, if: -> { ssn.present? && tin_type == "ssn" }
  validates :ssn, individual_taxpayer_identification_number: true, if: -> { ssn.present? && tin_type == "itin" }

  validate :ip_pins_format
  def ip_pins_format
    if ip_pin.present? && !/\d{6}/.match?(ip_pin.to_s)
      errors.add(:ip_pin, I18n.t("validators.ip_pin"))
    end
  end

  def full_name
    "#{first_name} #{last_name}"
  end

  def full_name_and_birth_date
    "#{full_name} #{birth_date.strftime("%-m/%-d/%Y")}"
  end

  def birth_date_year
    birth_date&.year
  end

  def birth_date_month
    birth_date&.month
  end

  def birth_date_day
    birth_date&.day
  end

  def error_summary
    if errors.present?
      concatenated_message_strings = errors.messages.map { |key, messages| messages.join(" ") }.join(" ")
      "Errors: " + concatenated_message_strings
    end
  end

  def age_at_end_of_tax_year
    age_at_end_of_year(intake.tax_year)
  end

  def age_at_end_of_year(tax_year)
    tax_year - birth_date.year
  end

  def eligible_for_child_tax_credit?(tax_year)
    # add additional eligibility logic
    age_at_end_of_year(tax_year) < 17
  end

  def mixpanel_data
    {
      dependent_age_at_end_of_tax_year: age_at_end_of_tax_year.to_s,
      dependent_under_6: age_at_end_of_tax_year < 6 ? "yes" : "no",
      dependent_months_in_home: months_in_home.to_s,
      dependent_was_student: was_student,
      dependent_on_visa: on_visa,
      dependent_north_american_resident: north_american_resident,
      dependent_disabled: disabled,
      dependent_was_married: was_married,
    }
  end
end
