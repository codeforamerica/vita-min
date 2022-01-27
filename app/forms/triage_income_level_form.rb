class TriageIncomeLevelForm < TriageForm
  include FormAttributes
  set_attributes_for :triage, :filing_status, :income_level, :source, :referrer, :locale, :visitor_id

  validates_presence_of :income_level
end
