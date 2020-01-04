class DisasterLossForm < QuestionsForm
  set_attributes_for :intake, :had_disaster_loss

  def save
    @intake.update(attributes_for(:intake))
  end
end