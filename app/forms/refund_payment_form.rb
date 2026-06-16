class RefundPaymentForm < QuestionsForm
  set_attributes_for :intake,
                     :refund_payment_method,
                     :refund_direct_deposit,
                     :refund_check_by_mail

  def save
    refund_direct_deposit = attributes_for(:intake)[:refund_direct_deposit]
    intake.update(
      refund_direct_deposit: refund_direct_deposit,
      refund_check_by_mail: refund_direct_deposit == 'yes' ? 'no' : 'yes',
      refund_payment_method: refund_direct_deposit == 'yes' ? 'direct_deposit' : 'check')
  end
end
