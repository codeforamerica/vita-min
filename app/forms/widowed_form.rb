class WidowedForm < QuestionsForm
  set_attributes_for :intake, :widowed

  def save
    @intake.update(attributes_for(:intake))
  end
end