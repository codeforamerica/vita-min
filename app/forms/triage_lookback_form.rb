class TriageLookbackForm < QuestionsForm
  set_attributes_for :triage_lookback, :had_income_decrease, :had_unemployment, :had_marketplace_insurance, :none
  validate :at_least_one_selection

  def initialize(form_params = {})
    super(nil, form_params)
  end

  def has_complex_situation?
    [had_income_decrease, had_unemployment, had_marketplace_insurance].any?("yes")
  end

  def at_least_one_selection
    if [had_income_decrease, had_unemployment, had_marketplace_insurance, none].all?("no")
      errors.add(:at_least_one_selection, "Please select at least one option to continue.")
    end
  end
end