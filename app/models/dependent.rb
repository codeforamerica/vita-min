# == Schema Information
#
# Table name: dependents
#
#  id                                          :bigint           not null, primary key
#  birth_date                                  :date
#  born_in_2020                                :integer          default("unfilled"), not null
#  can_be_claimed_by_other                     :integer          default("unfilled"), not null
#  claim_regardless                            :integer          default("unfilled"), not null
#  disabled                                    :integer          default("unfilled"), not null
#  encrypted_ip_pin                            :string
#  encrypted_ip_pin_iv                         :string
#  encrypted_ssn                               :string
#  encrypted_ssn_iv                            :string
#  filed_joint_return                          :integer          default("unfilled"), not null
#  first_name                                  :string
#  full_time_student                           :integer          default("unfilled"), not null
#  has_ip_pin                                  :integer          default("unfilled"), not null
#  last_name                                   :string
#  lived_with_less_than_six_months             :integer          default("unfilled"), not null
#  meets_misc_qualifying_relative_requirements :integer          default("unfilled"), not null
#  middle_initial                              :string
#  months_in_home                              :integer
#  no_ssn_atin                                 :integer          default("unfilled"), not null
#  north_american_resident                     :integer          default("unfilled"), not null
#  on_visa                                     :integer          default("unfilled"), not null
#  passed_away_2020                            :integer          default("unfilled"), not null
#  permanent_residence_with_client             :integer          default("unfilled"), not null
#  permanently_totally_disabled                :integer          default("unfilled"), not null
#  placed_for_adoption                         :integer          default("unfilled"), not null
#  provided_over_half_own_support              :integer          default("unfilled"), not null
#  relationship                                :string
#  tin_type                                    :integer
#  was_married                                 :integer          default("unfilled"), not null
#  was_student                                 :integer          default("unfilled"), not null
#  created_at                                  :datetime         not null
#  updated_at                                  :datetime         not null
#  intake_id                                   :bigint           not null
#
# Indexes
#
#  index_dependents_on_intake_id  (intake_id)
#

class Dependent < ApplicationRecord
  belongs_to :intake, inverse_of: :dependents

  attr_encrypted :ssn, key: ->(_) { EnvironmentCredentials.dig(:db_encryption_key) }
  attr_encrypted :ip_pin, key: ->(_) { EnvironmentCredentials.dig(:db_encryption_key) }

  auto_strip_attributes :ssn, :ip_pin, :first_name, :middle_initial, :last_name, virtual: true

  enum was_student: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :was_student
  enum on_visa: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :on_visa
  enum north_american_resident: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :north_american_resident
  enum disabled: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :disabled
  enum was_married: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :was_married
  enum tin_type: { ssn: 0, atin: 1, itin: 2, none: 3 }, _prefix: :tin_type
  enum has_ip_pin: { unfilled: 0, yes: 1, no: 2 }, _prefix: :has_ip_pin
  enum full_time_student: { unfilled: 0, yes: 1, no: 2 }, _prefix: :full_time_student
  enum permanently_totally_disabled: { unfilled: 0, yes: 1, no: 2 }, _prefix: :permanently_totally_disabled
  enum no_ssn_atin: { unfilled: 0, yes: 1, no: 2 }, _prefix: :no_ssn_atin
  enum provided_over_half_own_support: { unfilled: 0, yes: 1, no: 2 }, _prefix: :provided_over_half_own_support
  enum filed_joint_return: { unfilled: 0, yes: 1, no: 2 }, _prefix: :filed_joint_return
  enum lived_with_less_than_six_months: { unfilled: 0, yes: 1, no: 2 }, _prefix: :lived_with_less_than_six_months
  enum can_be_claimed_by_other: { unfilled: 0, yes: 1, no: 2 }, _prefix: :can_be_claimed_by_other
  enum born_in_2020: { unfilled: 0, yes: 1, no: 2 }, _prefix: :born_in_2020
  enum passed_away_2020: { unfilled: 0, yes: 1, no: 2 }, _prefix: :passed_away_2020
  enum placed_for_adoption: { unfilled: 0, yes: 1, no: 2 }, _prefix: :placed_for_adoption
  enum permanent_residence_with_client: { unfilled: 0, yes: 1, no: 2 }, _prefix: :permanent_residence_with_client
  enum claim_regardless: { unfilled: 0, yes: 1, no: 2 }, _prefix: :claim_regardless
  enum meets_misc_qualifying_relative_requirements: { unfilled: 0, yes: 1, no: 2 }, _prefix: :meets_misc_qualifying_relative_requirements

  validates_presence_of :first_name
  validates_presence_of :last_name

  # Allow birth date to be blank when we first create dependents in the CTC intake flow, but nowhere else
  validates_presence_of :birth_date, unless: -> { intake&.is_ctc? }
  validates_presence_of :birth_date, on: :ctc_valet_form

  validates_presence_of :relationship, on: :ctc_valet_form

  validates_presence_of :ssn, on: :ctc_valet_form
  validates_confirmation_of :ssn, if: -> { ssn.present? && ssn_changed? }
  validates :ssn, social_security_number: true, if: -> { ssn.present? && tin_type == "ssn" }
  validates :ssn, individual_taxpayer_identification_number: true, if: -> { ssn.present? && tin_type == "itin" }

  with_options on: :ip_pin_entry_form do
    validates :ip_pin, presence: true, if: -> { has_ip_pin_yes? }
  end

  validates :ip_pin, ip_pin: true

  QUALIFYING_CHILD_RELATIONSHIPS = [
    "Daughter",
    "Son",
    "Stepchild",
    "Foster child",
    "Grandchild",
    "Niece",
    "Nephew",
    "Half brother",
    "Half sister",
    "Brother",
    "Sister"
  ]

  QUALIFYING_RELATIVE_RELATIONSHIPS = [
    "Parent",
    "Grandparent",
    "Aunt",
    "Uncle"
  ]

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
    is_qualifying_child? && age_at_end_of_year(tax_year) < 17
  end

  def qualifying_child_relationship?
    QUALIFYING_CHILD_RELATIONSHIPS.include? relationship
  end

  def qualifying_relative_relationship?
    QUALIFYING_RELATIVE_RELATIONSHIPS.include? relationship
  end

  def qualifying_child?
    qualifying_child_relationship? &&
      ((full_time_student_yes? && age_at_end_of_year(2020) < 24) or permanently_totally_disabled_yes? or age_at_end_of_year(2020) < 19) &&
      (provided_over_half_own_support_no? && no_ssn_atin_no? && filed_joint_return_no?) &&
      lived_with_less_than_six_months_no? && (can_be_claimed_by_other_no? or claim_regardless_yes?)
  end

  def possibly_qualifying_child?
    qualifying_child_relationship? &&
      ((!full_time_student_no? && age_at_end_of_year(2020) < 24) || !permanently_totally_disabled_no? || age_at_end_of_year(2020) < 19) &&
      (!provided_over_half_own_support_yes? && !no_ssn_atin_yes? && !filed_joint_return_yes?) &&
      !lived_with_less_than_six_months_yes? && (!can_be_claimed_by_other_yes? || !claim_regardless_no?)
  end

  def qualifying_relative?
    !qualifying_child? &&
      (((qualifying_child_relationship? && age_at_end_of_year(2020) >= 19 && full_time_student_no?) ||
      (qualifying_child_relationship? && age_at_end_of_year(2020) > 24) ||
      (qualifying_child_relationship? && ((full_time_student_yes? && age_at_end_of_year(2020) < 24) || permanently_totally_disabled_yes? || (age_at_end_of_year(2020) < 19)) && filed_joint_return_yes?) ||
      qualifying_relative_relationship?) &&
      !provided_over_half_own_support_yes? && !no_ssn_atin_yes? &&
      meets_misc_qualifying_relative_requirements_yes?)
  end

  def possibly_qualifying_relative?
    !qualifying_child? &&
      (((qualifying_child_relationship? && age_at_end_of_year(2020) >= 19 && !full_time_student_yes?) ||
        (qualifying_child_relationship? && age_at_end_of_year(2020) > 24) ||
        (qualifying_child_relationship? && ((!full_time_student_no? && age_at_end_of_year(2020) < 24) || !permanently_totally_disabled_no? || (age_at_end_of_year(2020) < 19)) && !filed_joint_return_no?) ||
        qualifying_relative_relationship?) &&
        !provided_over_half_own_support_yes? && !no_ssn_atin_yes? &&
      !meets_misc_qualifying_relative_requirements_no?)
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
