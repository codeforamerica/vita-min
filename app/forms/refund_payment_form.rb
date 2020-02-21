class RefundPaymentForm < QuestionsForm
  set_attributes_for :intake, :refund_payment_method

  def save
    payment_method = attributes_for(:intake)[:refund_payment_method]
    payment_method = "unfilled" unless payment_method.present?

    intake.update(refund_payment_method: payment_method)
  end
end