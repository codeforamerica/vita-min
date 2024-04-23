class SuccessfullySubmittedForm < QuestionsForm
  set_attributes_for :intake, :feedback

  def save
    @intake.update(attributes_for(:intake))
  end
end