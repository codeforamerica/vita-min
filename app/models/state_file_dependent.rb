# == Schema Information
#
# Table name: state_file_dependents
#
#  id                :bigint           not null, primary key
#  ctc_qualifying    :boolean
#  dob               :date
#  eic_disability    :integer          default("unfilled")
#  eic_qualifying    :boolean
#  eic_student       :integer          default("unfilled")
#  first_name        :string
#  intake_type       :string           not null
#  last_name         :string
#  middle_initial    :string
#  months_in_home    :integer
#  needed_assistance :integer          default("unfilled"), not null
#  odc_qualifying    :boolean
#  passed_away       :integer          default("unfilled"), not null
#  relationship      :string
#  ssn               :string
#  suffix            :string
#  created_at        :datetime         not null
#  updated_at        :datetime         not null
#  intake_id         :bigint           not null
#
# Indexes
#
#  index_state_file_dependents_on_intake  (intake_type,intake_id)
#
class StateFileDependent < ApplicationRecord
  RELATIONSHIP_LABELS = {
    "DAUGHTER" => "Child",
    "STEPCHILD" => "Child",
    "FOSTER CHILD" => "Foster Child",
    "GRANDCHILD" => "Grandchild",
    "SISTER" => "Sibling",
    "HALF SISTER" => "Half-Sibling",
    "NEPHEW" => "Niece/Nephew",
    "STEPBROTHER" => "Step-Sibling",
    "PARENT" => "Parent",
    "GRANDPARENT" => "Grandparent",
    "NONE" => "Other",
  }.freeze

  belongs_to :intake, polymorphic: true
  encrypts :ssn
  enum needed_assistance: { unfilled: 0, yes: 1, no: 2 }, _prefix: :needed_assistance
  enum passed_away: { unfilled: 0, yes: 1, no: 2 }, _prefix: :passed_away
  enum eic_disability: { unfilled: 0, yes: 1, no: 2 }, _prefix: :eic_disability
  enum eic_student: { unfilled: 0, yes: 1, no: 2 }, _prefix: :eic_student

  # Create dob_* accessor methods for Honeycrisp's cfa_date_select
  delegate :month, :day, :year, to: :dob, prefix: :dob, allow_nil: true
  validates_presence_of :first_name, :last_name, :dob, on: :dob_form
  validates_presence_of :months_in_home, on: :dob_form, if: -> { self.intake_type == 'StateFileAzIntake' }
  validates :passed_away, :needed_assistance, inclusion: { in: %w[yes no], message: :blank }, on: :az_senior_form

  def self.senior_cutoff_date
    # Deprecated: please use `#senior?` (this method used only in tests)
    MultiTenantService.statefile.end_of_current_tax_year.years_ago(65)
  end

  def full_name
    parts = [first_name, middle_initial, last_name]
    parts << suffix if suffix.present?
    parts.compact.join(' ')
  end

  def ask_senior_questions?
    return false if dob.nil?
    senior? && months_in_home == 12 && ['PARENT', 'GRANDPARENT'].include?(relationship)
  end

  def is_qualifying_parent_or_grandparent?
    ask_senior_questions? && needed_assistance_yes?
  end

  def is_hoh_qualifying_person?
    relationship == 'PARENT' || (relationship != 'NONE' && (months_in_home || 0) >= 6)
  end

  def under_17?
    age < 17
  end

  def senior?
    age >= 65
  end

  def age
    MultiTenantService.statefile.current_tax_year - dob.year
  end

  def eligible_for_child_tax_credit
    return true if ctc_qualifying

    if relationship
      child_credit_qualifying_relationship = %w[daughter stepchild foster_child grandchild sister nephew half_sister stepbrother son brother niece half_brother stepsister].include?(relationship.downcase)
    end
    if under_17? && child_credit_qualifying_relationship
      return true
    end

    false
  end

  def relationship_label
    RELATIONSHIP_LABELS[relationship]
  end
end
