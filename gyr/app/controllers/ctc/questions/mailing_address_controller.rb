module Ctc
  module Questions
    class MailingAddressController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"

      def edit
        if (current_intake.bank_account.nil? || current_intake.bank_account.incomplete?) && current_intake.refund_payment_method_direct_deposit?
          redirect_to Ctc::Questions::BankAccountController.to_path_helper
        end

        super
      end
    end
  end
end