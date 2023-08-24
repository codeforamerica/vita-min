class BalancePaymentForm < QuestionsForm
  set_attributes_for :intake, :balance_pay_from_bank

  def save
    intake.update(attributes_for(:intake))
  end
end