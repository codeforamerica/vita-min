class TriageBacktaxesForm < QuestionsForm
  set_attributes_for :triage, :filed_previous_years

  def initialize(form_params={})
    super(nil, form_params)
  end

  def filed_previous_years?
    filed_previous_years == "yes"
  end
end