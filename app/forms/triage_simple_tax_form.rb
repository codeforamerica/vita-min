class TriageSimpleTaxForm < QuestionsForm
  set_attributes_for :simple_tax, :has_simple_taxes

  def initialize(form_params={})
    super(nil, form_params)
  end

  def has_simple_taxes?
    has_simple_taxes == "yes"
  end
end