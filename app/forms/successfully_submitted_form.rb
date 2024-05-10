class SuccessfullySubmittedForm < QuestionsForm
  set_attributes_for :intake, :feedback, :satisfaction_face
  before_validation :set_unfilled

  def save
    @intake.update(attributes_for(:intake))
  end

  private

  def set_unfilled
    self.satisfaction_face = :unfilled if satisfaction_face.blank?
  end
end
