# == Schema Information
#
# Table name: state_file_dependents
#
#  id                :bigint           not null, primary key
#  ctc_qualifying    :boolean
#  dob               :date
#  eic_disability    :boolean
#  eic_qualifying    :boolean
#  eic_student       :boolean
#  first_name        :string
#  intake_type       :string           not null
#  last_name         :string
#  middle_initial    :string
#  months_in_home    :integer
#  needed_assistance :integer          default("unfilled"), not null
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
  belongs_to :intake, polymorphic: true
  encrypts :ssn
  enum needed_assistance: { unfilled: 0, yes: 1, no: 2 }, _prefix: :needed_assistance
  enum passed_away: { unfilled: 0, yes: 1, no: 2 }, _prefix: :passed_away

  # Create birth_date_* accessor methods for Honeycrisp's cfa_date_select
  delegate :month, :day, :year, to: :dob, prefix: :dob, allow_nil: true
  validates_presence_of :first_name, :last_name, :dob, on: :dob_form
  validates_presence_of :months_in_home, on: :dob_form, if: -> { self.intake_type == 'StateFileAzIntake' }
  validates :passed_away, :needed_assistance, inclusion: { in: %w[yes no], message: I18n.t("errors.messages.blank") }, on: :az_senior_form

  scope :az_qualifying_senior, -> do
    where(['dob <= ?', senior_cutoff_date])
      .where(months_in_home: 12)
      .where(relationship: ['PARENT', 'GRANDPARENT'])
  end
  ELIGIBLE_CTC = 'EligibleForChildTaxCreditInd'.freeze

  def full_name
    parts = [first_name, middle_initial, last_name]
    parts << suffix if suffix.present?
    parts.compact.join(' ')
  end

  def ask_senior_questions?
    return false if dob.nil?
    dob <= StateFileDependent.senior_cutoff_date && months_in_home == 12 && (relationship == 'PARENT' || relationship == 'GRANDPARENT')
  end

  def self.senior_cutoff_date
    MultiTenantService.statefile.end_of_current_tax_year.years_ago(65)
  end

  def age
    ((MultiTenantService.statefile.end_of_current_tax_year.to_time - dob.to_time) / 1.year.seconds).floor
  end

  def eligible_for_child_tax_credit
    dependents = self.intake&.direct_file_data&.parsed_xml&.css('DependentDetail')
    dependents.any? do |dep|
      dp_str = dep.to_s
      (ELIGIBLE_CTC.in? dp_str) && (self.first_name.in? dp_str) && (self.last_name.in? dp_str) && (self.ssn.in? dp_str)
    end
  end

  def eligible_for_eitc
    dependents = self.intake&.direct_file_data&.parsed_xml&.css('IRS1040ScheduleEIC QualifyingChildInformation')
    dependents.any? do |dep|
      dp_str = dep.to_s
      (self.first_name.in? dp_str) && (self.last_name.in? dp_str) && (self.ssn.in? dp_str)
    end
  end
end
