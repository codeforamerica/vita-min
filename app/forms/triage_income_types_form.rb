class TriageIncomeTypesForm < TriageForm
  include FormAttributes

  set_attributes_for :triage, :income_type_rent, :income_type_farm
  set_attributes_for :misc, :none_of_the_above

  validates :none_of_the_above, at_least_one_or_none_of_the_above_selected: true

  def at_least_one_selected
    income_type_rent == "yes" ||
      income_type_farm == "yes"
  end
end
