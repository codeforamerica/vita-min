class SuccessfullySubmittedForm < QuestionsForm
  set_attributes_for :intake, :feedback, :satisfaction_face

  def save
    @intake.update(attributes_for(:intake))
  end
end