class SavingsOptionsForm < QuestionsForm
  set_attributes_for :intake, :savings_purchase_bond, :savings_split_refund

  def save
    intake.update(attributes_for(:intake))
  end
end