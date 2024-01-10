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


  def full_name
    parts = [first_name, middle_initial, last_name]
    parts << suffix if suffix.present?
    parts.compact.join(' ')
  end

  def ask_senior_questions?
    return false if dob.nil?
    dob <= StateFileDependent.senior_cutoff_date && months_in_home == 12 && (relationship == 'PARENT' || relationship == 'GRANDPARENT')
  end

  def is_qualifying_parent_or_grandparent?
    ask_senior_questions? && needed_assistance_yes?
  end

  def self.senior_cutoff_date
    MultiTenantService.statefile.end_of_current_tax_year.years_ago(65)
  end

  def age
    ((MultiTenantService.statefile.end_of_current_tax_year.to_time - dob.to_time) / 1.year.seconds).floor
  end
end
