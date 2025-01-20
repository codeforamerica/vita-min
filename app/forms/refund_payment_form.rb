class RefundPaymentForm < QuestionsForm
  set_attributes_for :intake, :refund_payment_method, :refund_direct_deposit, :refund_check_by_mail

  def save
    payment_method = attributes_for(:intake)[:refund_payment_method]
    payment_method = "unfilled" unless payment_method.present?
    intake.update(refund_payment_method: payment_method)

    if payment_method == 'direct_deposit'
      intake.update(refund_direct_deposit: 'yes')
      intake.update(refund_check_by_mail: 'unfilled')
    else
      intake.update(refund_direct_deposit: 'unfilled')
      intake.update(refund_check_by_mail: 'yes')
    end

  end
end
