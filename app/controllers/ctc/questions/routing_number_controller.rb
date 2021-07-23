module Ctc
  module Questions
    class RoutingNumberController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"

      def self.show?(intake, _dependent)
        intake.refund_payment_method_direct_deposit?
      end

      private

      def illustration_path
        "bank-details.svg"
      end
    end
  end
end