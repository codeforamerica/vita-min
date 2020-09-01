class SpouseWasBlindForm < QuestionsForm
  set_attributes_for :intake, :spouse_was_blind

  def save
    @intake.update(attributes_for(:intake))
  end
end