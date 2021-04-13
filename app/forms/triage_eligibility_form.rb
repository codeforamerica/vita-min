class TriageEligibilityForm < QuestionsForm
  set_attributes_for :triage, :had_farm_income, :had_rental_income, :income_over_limit

  def initialize(form_params = {})
    super(nil, form_params)
  end

  def eligible?
    [had_farm_income, had_rental_income, income_over_limit].all?("no")
  end
end