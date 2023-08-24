module Ctc
  module Questions
    class ConfirmBankAccountController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"

      def edit
        if current_intake.bank_account.nil? || current_intake.bank_account.incomplete?
          redirect_to Ctc::Questions::BankAccountController.to_path_helper
        end

        super
      end

      def self.show?(intake)
        intake.refund_payment_method_direct_deposit?
      end

      private

      def form_class
        NullForm
      end

      def illustration_path
        "bank-details.svg"
      end
    end
  end
end
