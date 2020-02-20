class WasBlindForm < QuestionsForm
  set_attributes_for :intake, :was_blind

  def save
    @intake.update(attributes_for(:intake))
  end
end