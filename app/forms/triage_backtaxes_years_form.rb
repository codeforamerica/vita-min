class TriageBacktaxesYearsForm < TriageForm
  include FormAttributes
  set_attributes_for :triage, :filed_2018, :filed_2019, :filed_2020, :filed_2021
end
