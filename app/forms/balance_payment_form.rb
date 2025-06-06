class BalancePaymentForm < QuestionsForm
  set_attributes_for :intake, :balance_pay_from_bank, :payment_in_installments
  attr_accessor :balance_payment_choice

  def save
    intake.update(attributes_for(:intake))
  end
end