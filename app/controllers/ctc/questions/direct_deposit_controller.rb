module Ctc
  module Questions
    class DirectDepositController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"

      def self.show?(intake)
        intake.refund_payment_method_direct_deposit?
      end

      def self.i18n_base_path
        "views.questions.bank_details"
      end

      private

      def illustration_path
        "bank-details.svg"
      end
    end
  end
end
