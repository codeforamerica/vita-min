module Ctc
  module Questions
    class DirectDepositController < QuestionsController
      include AuthenticatedCtcClientConcern

      def self.deprecated_controller?
        true
      end

      def self.show?(_intake)
        false
      end

      def edit
        redirect_to Ctc::Questions::BankAccountController.to_path_helper
      end

      def update
        redirect_to Ctc::Questions::BankAccountController.to_path_helper
      end
    end
  end
end
