class SpouseOnVisaForm < QuestionsForm
  set_attributes_for :intake, :spouse_was_on_visa

  def save
    @intake.update(attributes_for(:intake))
  end
end