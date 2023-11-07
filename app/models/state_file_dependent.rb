# == Schema Information
#
# Table name: state_file_dependents
#
#  id                :bigint           not null, primary key
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
  validates_presence_of :dob, on: :dob_form
  validates :needed_assistance, inclusion: { in: %w[yes no], message: I18n.t("errors.messages.blank") }, on: :az_senior_form
  validates :passed_away, inclusion: { in: %w[yes no], message: I18n.t("errors.messages.blank") }, on: :az_senior_form

  scope :az_qualifying_senior, -> do
    where(['dob <= ?', senior_cutoff_date])
      .where(months_in_home: 12)
      .where(relationship: ['PARENT', 'GRANDPARENT'])
  end

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
end
