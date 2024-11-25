# == Schema Information
#
# Table name: state_file_dependents
#
#  id                                      :bigint           not null, primary key
#  ctc_qualifying                          :boolean
#  dob                                     :date
#  eic_disability                          :integer          default("unfilled")
#  eic_qualifying                          :boolean
#  eic_student                             :integer          default("unfilled")
#  first_name                              :string
#  id_has_grocery_credit_ineligible_months :integer          default("unfilled"), not null
#  id_months_ineligible_for_grocery_credit :integer
#  intake_type                             :string           not null
#  last_name                               :string
#  middle_initial                          :string
#  months_in_home                          :integer
#  needed_assistance                       :integer          default("unfilled"), not null
#  odc_qualifying                          :boolean
#  passed_away                             :integer          default("unfilled"), not null
#  qualifying_child                        :boolean
#  relationship                            :string
#  ssn                                     :string
#  suffix                                  :string
#  created_at                              :datetime         not null
#  updated_at                              :datetime         not null
#  intake_id                               :bigint           not null
#
# Indexes
#
#  index_state_file_dependents_on_intake  (intake_type,intake_id)
#

class StateFileDependent < ApplicationRecord

  RELATIONSHIP_LABELS = {
    "biologicalChild" => "Child",
    "adoptedChild" => "Child",
    "stepChild" => "Child",
    "fosterChild" => "Foster Child",
    "grandChildOrOtherDescendentOfChild" => "Grandchild",
    "childInLaw" => "Child",
    "sibling" => "Sibling",
    "childOfSibling" => "Niece/Nephew",
    "halfSibling" => "Half-Sibling",
    "childOfHalfSibling" => "Niece/Nephew",
    "stepSibling" => "Step-Sibling",
    "childOfStepSibling" => "Niece/Nephew",
    "otherDescendantOfSibling" => "Niece/Nephew",
    "siblingInLaw" => "Sibling",
    "parent" => "Parent",
    "grandParent" => "Grandparent",
    "otherAncestorOfParent" => "Grandparent",
    "stepParent" => "Parent",
    "parentInLaw" => "Parent",
    "noneOfTheAbove" => "Other",
    "siblingOfParent" => "Aunt/Uncle",
    "otherDescendantOfHalfSibling" => "Niece/Nephew",
    "otherDescendantOfStepSibling" => "Niece/Nephew",
    "fosterParent" => "Parent",
    "siblingsSpouse" => "Sibling-in-Law",
  }.freeze

  belongs_to :intake, polymorphic: true
  encrypts :ssn
  enum needed_assistance: { unfilled: 0, yes: 1, no: 2 }, _prefix: :needed_assistance
  enum passed_away: { unfilled: 0, yes: 1, no: 2 }, _prefix: :passed_away
  enum eic_disability: { unfilled: 0, yes: 1, no: 2 }, _prefix: :eic_disability
  enum eic_student: { unfilled: 0, yes: 1, no: 2 }, _prefix: :eic_student
  enum id_has_grocery_credit_ineligible_months: { unfilled: 0, yes: 1, no: 2 }, _prefix: :id_has_grocery_credit_ineligible_months

  # Create dob_* accessor methods for Honeycrisp's cfa_date_select
  delegate :month, :day, :year, to: :dob, prefix: :dob, allow_nil: true
  validates_presence_of :first_name, :last_name, :dob
  validates :passed_away, :needed_assistance, inclusion: { in: %w[yes no], message: :blank }, on: :az_senior_form

  validates :id_months_ineligible_for_grocery_credit, numericality: {
    greater_than_or_equal_to: 0,
    message: :blank
  }, if: -> { id_has_grocery_credit_ineligible_months == "yes" }, on: :id_grocery_credit_form

  def self.senior_cutoff_date
    # Deprecated: please use `#senior?` (this method used only in tests)
    MultiTenantService.statefile.end_of_current_tax_year.years_ago(65)
  end

  def full_name
    parts = [first_name, middle_initial, last_name]
    parts << suffix if suffix.present?
    parts.compact.join(' ')
  end

  def months_in_home_for_pdf
    months_in_home&.to_s || "<6"
  end

  def months_in_home_for_xml
    months_in_home || 5
  end

  def ask_senior_questions?
    return false if dob.nil?
    senior? && months_in_home == 12 && ['parent', 'grandParent', 'otherAncestorOfParent'].include?(relationship)
  end

  def is_qualifying_parent_or_grandparent?
    ask_senior_questions? && needed_assistance_yes?
  end

  def is_hoh_qualifying_person?
    relationship == 'parent' || (relationship != 'noneOfTheAbove' && (months_in_home || 0) >= 6)
  end

  def under_17?
    calculate_age(inclusive_of_jan_1: false) < 17
  end

  def senior?
    calculate_age(inclusive_of_jan_1: true) >= 65
  end

  def calculate_age(inclusive_of_jan_1:)
    intake.calculate_age(dob, inclusive_of_jan_1: inclusive_of_jan_1)
  end

  def eligible_for_child_tax_credit
    return true if ctc_qualifying

    if under_17?
      if [
        # daughter
        "biologicalChild",
        "adoptedChild",
        "childInLaw",

        # stepchild
        "stepChild",

        # foster_child
        "fosterChild",

        # grandchild
        "grandChildOrOtherDescendentOfChild",

        # sister
        "sibling",
        "siblingInLaw",
        "siblingsSpouse",

        # nephew
        "childOfSibling",
        "childOfHalfSibling",
        "childOfStepSibling",
        "otherDescendantOfSibling",
        "otherDescendantOfHalfSibling",
        "otherDescendantOfStepSibling",

        # half_sister
        "halfSibling",

        # stepbrother
        "stepSibling"
      ].include?(relationship)
        return true
      end
    end

    false
  end

  def relationship_label
    RELATIONSHIP_LABELS[relationship]
  end
end
