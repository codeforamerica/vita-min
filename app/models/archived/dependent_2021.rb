# == Schema Information
#
# Table name: archived_dependents_2021
#
#  id                                          :bigint           not null, primary key
#  birth_date                                  :date             not null
#  born_in_2020                                :integer          default("unfilled"), not null
#  cant_be_claimed_by_other                    :integer          default("unfilled"), not null
#  claim_anyway                                :integer          default("unfilled"), not null
#  creation_token                              :string
#  disabled                                    :integer          default("unfilled"), not null
#  filed_joint_return                          :integer          default("unfilled"), not null
#  first_name                                  :string
#  full_time_student                           :integer          default("unfilled"), not null
#  has_ip_pin                                  :integer          default("unfilled"), not null
#  ip_pin                                      :text
#  last_name                                   :string
#  lived_with_more_than_six_months             :integer          default("unfilled"), not null
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
#  soft_deleted_at                             :datetime
#  ssn                                         :text
#  suffix                                      :string
#  tin_type                                    :integer
#  was_married                                 :integer          default("unfilled"), not null
#  was_student                                 :integer          default("unfilled"), not null
#  created_at                                  :datetime         not null
#  updated_at                                  :datetime         not null
#  archived_intakes_2021_id                    :bigint           not null
#
# Indexes
#
#  index_archived_dependents_2021_on_archived_intakes_2021_id  (archived_intakes_2021_id)
#  index_archived_dependents_2021_on_creation_token            (creation_token)
#
# Foreign Keys
#
#  fk_rails_...  (archived_intakes_2021_id => archived_intakes_2021.id)
#
module Archived
  class Dependent2021 < ApplicationRecord
    self.table_name = 'archived_dependents_2021'
    self.ignored_columns = ["encrypted_ssn", "encrypted_ssn_iv", "encrypted_ip_pin", "encrypted_ip_pin_iv"]

    include SoftDeletable

    belongs_to :intake, inverse_of: :dependents, foreign_key: 'archived_intakes_2021_id', class_name: 'Archived::Intake2021'


    encrypts :ssn, :ip_pin

    auto_strip_attributes :ssn, :ip_pin, :first_name, :middle_initial, :last_name, virtual: true

    enum was_student: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :was_student
    enum on_visa: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :on_visa
    enum north_american_resident: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :north_american_resident
    enum disabled: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :disabled
    enum was_married: { unfilled: 0, yes: 1, no: 2, unsure: 3 }, _prefix: :was_married
    enum tin_type: { ssn: 0, atin: 1, itin: 2, none: 3, ssn_no_employment: 4 }, _prefix: :tin_type
    enum has_ip_pin: { unfilled: 0, yes: 1, no: 2 }, _prefix: :has_ip_pin
    enum full_time_student: { unfilled: 0, yes: 1, no: 2 }, _prefix: :full_time_student
    enum permanently_totally_disabled: { unfilled: 0, yes: 1, no: 2 }, _prefix: :permanently_totally_disabled
    enum no_ssn_atin: { unfilled: 0, yes: 1, no: 2 }, _prefix: :no_ssn_atin
    enum provided_over_half_own_support: { unfilled: 0, yes: 1, no: 2 }, _prefix: :provided_over_half_own_support
    enum filed_joint_return: { unfilled: 0, yes: 1, no: 2 }, _prefix: :filed_joint_return
    enum lived_with_more_than_six_months: { unfilled: 0, yes: 1, no: 2 }, _prefix: :lived_with_more_than_six_months
    enum cant_be_claimed_by_other: { unfilled: 0, yes: 1, no: 2 }, _prefix: :cant_be_claimed_by_other
    enum born_in_2020: { unfilled: 0, yes: 1, no: 2 }, _prefix: :born_in_2020
    enum passed_away_2020: { unfilled: 0, yes: 1, no: 2 }, _prefix: :passed_away_2020
    enum placed_for_adoption: { unfilled: 0, yes: 1, no: 2 }, _prefix: :placed_for_adoption
    enum permanent_residence_with_client: { unfilled: 0, yes: 1, no: 2 }, _prefix: :permanent_residence_with_client
    enum claim_anyway: { unfilled: 0, yes: 1, no: 2 }, _prefix: :claim_anyway
    enum meets_misc_qualifying_relative_requirements: { unfilled: 0, yes: 1, no: 2 }, _prefix: :meets_misc_qualifying_relative_requirements

    before_destroy :remove_error_associations

    validates_presence_of :first_name
    validates_presence_of :last_name

    validates_presence_of :birth_date
    # Create birth_date_* accessor methods for Honeycrisp's cfa_date_select
    delegate :month, :day, :year, to: :birth_date, prefix: :birth_date, allow_nil: true

    validates_presence_of :relationship, on: :ctc_valet_form

    validates_presence_of :ssn, on: :ctc_valet_form
    validates_confirmation_of :ssn, if: -> { ssn.present? && ssn_changed? }
    validates :ssn, social_security_number: true, if: -> { ssn.present? && tin_type == "ssn" }
    validates :ssn, individual_taxpayer_identification_number: true, if: -> { ssn.present? && tin_type == "itin" }

    with_options on: :ip_pin_entry_form do
      validates :ip_pin, presence: true, if: -> { has_ip_pin_yes? }
    end

    validates :ip_pin, ip_pin: true

    before_validation do
      self.ssn = self.ssn.remove(/\D/) if ssn_changed? && self.ssn
    end

    QUALIFYING_CHILD_RELATIONSHIPS = %w[daughter son stepchild stepbrother stepsister foster_child grandchild niece nephew half_brother half_sister brother sister]

    QUALIFYING_RELATIVE_RELATIONSHIPS = %w[parent grandparent aunt uncle]


    def full_name
      parts = [first_name, middle_initial, last_name]
      parts << suffix if suffix.present?
      parts.compact.join(' ')
    end

    def error_summary
      if errors.present?
        concatenated_message_strings = errors.messages.map { |key, messages| messages.join(" ") }.join(" ")
        "Errors: " + concatenated_message_strings
      end
    end

    # Transforms relationship to the format expected by the IRS submission
    # (upcased with spaces instead of underscores)
    def irs_relationship_enum
      relationship&.upcase.gsub("_", " ")
    end

    def eligible_for_child_tax_credit_2020?
      yr_2020_age < 17 && yr_2020_qualifying_child? && tin_type_ssn?
    end

    def eligible_for_eip1?
      yr_2020_age < 17 && yr_2020_qualifying_child? && [:ssn, :atin].include?(tin_type&.to_sym)
    end

    def eligible_for_eip2?
      yr_2020_age < 17 && yr_2020_qualifying_child? && [:ssn, :atin].include?(tin_type&.to_sym)
    end

    def eligible_for_eip3?
      yr_2020_qualifying_child? || yr_2020_qualifying_relative?
    end

    def qualifying_child_relationship?
      QUALIFYING_CHILD_RELATIONSHIPS.include? relationship.downcase
    end

    def qualifying_relative_relationship?
      QUALIFYING_RELATIVE_RELATIONSHIPS.include? relationship.downcase
    end

    def meets_qc_misc_conditions?
      provided_over_half_own_support_no? && filed_joint_return_no?
    end

    def meets_qc_claimant_condition?
      cant_be_claimed_by_other_yes? ||
        (cant_be_claimed_by_other_no? && claim_anyway_yes?)
    end

    def meets_qc_residence_condition_generic?
      # This method should only be called when creating the `Rules` instance.
      #
      # The age check is handled in the year-specific rules; the rest is handled here.
      lived_with_more_than_six_months_yes? ||
        (lived_with_more_than_six_months_no? &&
          (born_in_2020_yes? || passed_away_2020_yes? || placed_for_adoption_yes? || permanent_residence_with_client_yes?))
    end

    def mixpanel_data
      {
        dependent_age_at_end_of_tax_year: yr_2020_age.to_s,
        dependent_under_6: yr_2020_age < 6 ? "yes" : "no",
        dependent_months_in_home: months_in_home.to_s,
        dependent_was_student: was_student,
        dependent_on_visa: on_visa,
        dependent_north_american_resident: north_american_resident,
        dependent_disabled: disabled,
        dependent_was_married: was_married,
      }
    end

    # Methods on Dependent::Rules can be accessed (and mocked-out) as yr_2020_* and yr_2021_*. In the future, we might
    # add a default year with no prefix.
    delegate :age, :born_in_final_6_months?, :disqualified_child_qualified_relative?, :meets_qc_age_condition?, :meets_qc_residence_condition?, :qualifying_child?, :qualifying_relative?, to: :rules_2020, prefix: :yr_2020
    delegate :age, :born_in_final_6_months?, :disqualified_child_qualified_relative?, :meets_qc_age_condition?, :meets_qc_residence_condition?, :qualifying_child?, :qualifying_relative?, to: :rules_2021, prefix: :yr_2021

    private

    def rules_2020
      rules(2020)
    end

    def rules_2021
      rules(2021)
    end

    def rules(year)
      Rules.new(birth_date, year, full_time_student_yes?, permanently_totally_disabled_yes?, ssn.present?, qualifying_child_relationship?, qualifying_relative_relationship?, meets_misc_qualifying_relative_requirements_yes?, meets_qc_residence_condition_generic?, meets_qc_claimant_condition?, meets_qc_misc_conditions?)
    end

    def remove_error_associations
      EfileSubmissionTransitionError.where(dependent_id: self.id).update_all(dependent_id: nil)
    end
  end

  class Rules
    def initialize(birth_date, tax_year, full_time_student_yes, permanently_totally_disabled_yes, ssn_present, qualifying_child_relationship, qualifying_relative_relationship, meets_misc_qualifying_relative_requirements_yes, meets_qc_residence_condition_generic, meets_qc_claimant_condition, meets_qc_misc_conditions)
      @birth_date = birth_date
      @tax_year = tax_year
      @full_time_student_yes = full_time_student_yes
      @permanently_totally_disabled_yes = permanently_totally_disabled_yes
      @ssn_present = ssn_present
      @qualifying_child_relationship = qualifying_child_relationship
      @qualifying_relative_relationship = qualifying_relative_relationship
      @meets_misc_qualifying_relative_requirements_yes = meets_misc_qualifying_relative_requirements_yes
      @meets_qc_residence_condition_generic = meets_qc_residence_condition_generic
      @meets_qc_claimant_condition = meets_qc_claimant_condition
      @meets_qc_misc_conditions = meets_qc_misc_conditions

      # For tax year e.g. 1999, someone is 1 year old if born on any day in 1998.
      @age = @tax_year - @birth_date.year
    end

    def born_in_final_6_months?
      @birth_date >= Date.new(@tax_year, 6, 30) && @birth_date <= Date.new(@tax_year, 12, 31)
    end

    def age; @age; end

    def meets_qc_age_condition?
      @age >= 0 && (
      @permanently_totally_disabled_yes ||
        (@age < 19) ||
        (@full_time_student_yes && @age < 24)
      )
    end

    def disqualified_child_qualified_relative?
      @age >= 0 && (
      @qualifying_child_relationship && !meets_qc_age_condition?
      )
    end

    def qualifying_relative?
      @meets_misc_qualifying_relative_requirements_yes &&
        @ssn_present &&
        (disqualified_child_qualified_relative? || @qualifying_relative_relationship)
    end

    def meets_qc_residence_condition?
      @meets_qc_residence_condition_generic || born_in_final_6_months?
    end

    def qualifying_child?
      @qualifying_child_relationship &&
        @ssn_present &&
        @meets_qc_claimant_condition &&
        @meets_qc_misc_conditions &&
        meets_qc_age_condition? &&
        meets_qc_residence_condition?
    end
  end
end
