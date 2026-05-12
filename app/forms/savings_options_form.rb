class SavingsOptionsForm < QuestionsForm
  set_attributes_for :intake, :savings_split_refund

  def save
    @intake.update(attributes_for(:intake))
  end
end
