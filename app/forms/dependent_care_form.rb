class DependentCareForm < QuestionsForm
  set_attributes_for :intake, :paid_dependent_care

  def save
    @intake.update(attributes_for(:intake))
  end
end