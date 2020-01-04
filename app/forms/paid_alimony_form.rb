class PaidAlimonyForm < QuestionsForm
  set_attributes_for :intake, :paid_alimony

  def save
    @intake.update(attributes_for(:intake))
  end
end