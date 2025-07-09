class BalancePaymentForm < QuestionsForm
  set_attributes_for :intake, :balance_pay_from_bank, :payment_in_installments, :balance_payment_choice
  attr_accessor :balance_payment_choice

  validates :balance_payment_choice, presence: { message: I18n.t('views.questions.balance_payment.error_message') }

  def save
    case balance_payment_choice
    when "bank"
      self.balance_pay_from_bank = "yes"
      self.payment_in_installments = "no"
    when "mail"
      self.balance_pay_from_bank = "no"
      self.payment_in_installments = "no"
    when "installments"
      self.balance_pay_from_bank = "unfilled"
      self.payment_in_installments = "yes"
    else
      nil
    end
    intake.update(attributes_for(:intake).except(:balance_payment_choice))
  end

  def self.existing_attributes(intake)
    already_answered = !intake.balance_pay_from_bank_unfilled? || !intake.payment_in_installments_unfilled?
    if already_answered
      balance_payment_choice = case [intake.balance_pay_from_bank, intake.payment_in_installments]
                               when %w[yes no]
                                 "bank"
                               when %w[no no]
                                 "mail"
                               when %w[unfilled yes]
                                 "installments"
                               else
                                 nil
                               end
      super.merge(balance_payment_choice: balance_payment_choice)
    else
      super
    end
  end
end