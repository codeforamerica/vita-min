module Ctc
  module Portal
    class RefundPaymentForm < QuestionsForm
      include FormAttributes

      set_attributes_for :intake, :refund_payment_method
      validates_presence_of :refund_payment_method

      def save
        @intake.bank_account&.destroy if @intake.refund_payment_method == "direct_deposit" && refund_payment_method == "check" && @intake.bank_account.present?

        @intake.update(attributes_for(:intake))
      end
    end
  end
end