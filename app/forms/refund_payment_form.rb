class RefundPaymentForm < QuestionsForm
  set_attributes_for :intake, :refund_payment_method, :refund_direct_deposit, :refund_check_by_mail

  def save
    payment_method = attributes_for(:intake)[:refund_payment_method]
    payment_method = "unfilled" unless payment_method.present?
    intake.update(refund_payment_method: payment_method)

    # While the single field `refund_payment_method` is used for the intake flow, we
    # use separate fields for the Hub so that form elements (in the erb file) can
    # each refer to a distinct field. So we assign values to those fields here.
    if payment_method == 'direct_deposit'
      intake.update(refund_direct_deposit: 'yes')
      intake.update(refund_check_by_mail: 'no')
    else
      intake.update(refund_direct_deposit: 'no')
      intake.update(refund_check_by_mail: 'yes')
    end
  end
end
