class BalancePaymentForm < QuestionsForm
  set_attributes_for :intake, :balance_pay_from_bank, :payment_in_installments
  attr_accessor :balance_payment_choice

  def save
    case balance_payment_choice
    when "yes"
      self.balance_pay_from_bank = "yes"
      self.payment_in_installments = "no"
    when "no"
      self.balance_pay_from_bank = "no"
      self.payment_in_installments = "no"
    else
      self.balance_pay_from_bank = "no"
      self.payment_in_installments = "yes"
    end
  end
end