class TriageIncomeLevelForm < TriageForm
  include FormAttributes
  set_attributes_for :triage, :filing_status, :income_level, :source, :referrer, :locale, :visitor_id

  validates :income_level, presence: true, inclusion: Triage.income_levels.keys
end
