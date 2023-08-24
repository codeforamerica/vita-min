module Ctc
  class RefundPaymentForm < QuestionsForm
    set_attributes_for :intake, :refund_payment_method

    validates_presence_of :refund_payment_method

    def save
      @intake.update(attributes_for(:intake))
    end
  end
end