class ReceivedAlimonyForm < QuestionsForm
  set_attributes_for :intake, :received_alimony

  def save
    @intake.update(attributes_for(:intake))
  end
end