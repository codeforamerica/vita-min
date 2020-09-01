class OnVisaForm < QuestionsForm
  set_attributes_for :intake, :was_on_visa

  def save
    @intake.update(attributes_for(:intake))
  end
end