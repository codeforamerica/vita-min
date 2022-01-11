class TriageBacktaxesYearsForm < TriageForm
  include FormAttributes
  set_attributes_for :triage, :backtaxes_2018, :backtaxes_2019, :backtaxes_2020, :backtaxes_2021
end
