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

  validates_presence_of :first_name, message: "Please enter a first name."
  validates_presence_of :last_name, message: "Please enter a last name."
  validates_presence_of :birth_date, message: "Please enter a valid date."

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
end
