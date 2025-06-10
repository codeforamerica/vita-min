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
    
    intake.update(attributes_for(:intake))
  end

  def self.existing_attributes(intake)
    attributes = HashWithIndifferentAccess.new
    if intake.balance_pay_from_bank_yes?
      attributes[:balance_payment_choice] = "yes"
    elsif intake.balance_pay_from_bank_no?
      attributes[:balance_payment_choice] = if intake.payment_in_installments_yes?
                                              "installments"
                                            else
                                              "no"
                                            end
    end
    attributes
  end
end