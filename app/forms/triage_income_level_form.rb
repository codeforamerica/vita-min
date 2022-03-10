class TriageIncomeLevelForm < QuestionsForm
  set_attributes_for :intake, :triage_filing_status, :triage_income_level, :triage_filing_frequency, :triage_vita_income_ineligible

  validates :triage_income_level, presence: true, inclusion: Intake::GyrIntake.triage_income_levels.keys
  validates :triage_filing_status, presence: true, inclusion: Intake::GyrIntake.triage_filing_statuses.keys
  validates :triage_filing_frequency, presence: true, inclusion: Intake::GyrIntake.triage_filing_frequencies.keys
  validates :triage_vita_income_ineligible, presence: true, inclusion: Intake::GyrIntake.triage_vita_income_ineligibles.keys

  def save
    @intake.update(attributes_for(:intake))
  end
end
