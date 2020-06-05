# == Schema Information
#
# Table name: dependents
#
#  id                      :bigint           not null, primary key
#  birth_date              :date
#  disabled                :integer          default("unfilled"), not null
#  first_name              :string
#  last_name               :string
#  months_in_home          :integer
#  north_american_resident :integer          default("unfilled"), not null
#  on_visa                 :integer          default("unfilled"), not null
#  relationship            :string
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
  belongs_to :intake

  enum was_student: { unfilled: 0, yes: 1, no: 2 }, _prefix: :was_student
  enum on_visa: { unfilled: 0, yes: 1, no: 2 }, _prefix: :on_visa
  enum north_american_resident: { unfilled: 0, yes: 1, no: 2 }, _prefix: :north_american_resident
  enum disabled: { unfilled: 0, yes: 1, no: 2 }, _prefix: :disabled
  enum was_married: { unfilled: 0, yes: 1, no: 2 }, _prefix: :was_married

  validates_presence_of :first_name, message: I18n.t("models.dependent.validators.first_name_presence")
  validates_presence_of :last_name, message: I18n.t("models.dependent.validators.last_name_presence")
  validates_presence_of :birth_date, message: I18n.t("models.dependent.validators.birth_date_presence")

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
    intake.tax_year - birth_date.year
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
