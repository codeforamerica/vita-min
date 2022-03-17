class TriageIncomeLevelForm < QuestionsForm
  set_attributes_for :intake, :triage_filing_status, :triage_income_level, :triage_filing_frequency, :triage_vita_income_ineligible

  validates :triage_income_level, presence: true
  validates :triage_income_level, inclusion: Intake::GyrIntake.triage_income_levels.keys, if: -> { triage_income_level.present? }
  validates :triage_filing_status, presence: true
  validates :triage_filing_status, inclusion: Intake::GyrIntake.triage_filing_statuses.keys, if: -> { triage_filing_status.present? }
  validates :triage_filing_frequency, presence: true
  validates :triage_filing_frequency, inclusion: Intake::GyrIntake.triage_filing_frequencies.keys, if: -> { triage_filing_frequency.present? }
  validates :triage_vita_income_ineligible, presence: true
  validates :triage_vita_income_ineligible, inclusion: Intake::GyrIntake.triage_vita_income_ineligibles.keys, if: -> { triage_vita_income_ineligible.present? }

  def save
    @intake.update(attributes_for(:intake))
  end
end
