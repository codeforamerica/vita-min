class SatisfactionFaceForm < QuestionsForm
  set_attributes_for :intake, :satisfaction_face

  def save
    @intake.update(attributes_for(:intake))
  end
end