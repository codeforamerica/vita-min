module Ctc
  module Portal
    class RefundPaymentForm < Form
      include FormAttributes

      set_attributes_for :intake, :refund_payment_method
      validates_presence_of :refund_payment_method

      def initialize(intake, params = {})
        @intake = intake
        super(params)
      end

      def save
        @intake.update(attributes_for(:intake))
      end
    end
  end
end