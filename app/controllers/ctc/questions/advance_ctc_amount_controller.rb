module Ctc
  module Questions
    class AdvanceCtcAmountController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"

      def self.show?(intake)
        intake.advance_ctc_amount_received.nil? && intake.dependents.count(&:qualifying_ctc?).positive?
      end

      private

      def illustration_path
        "hand-holding-cash-and-check.svg"
      end
    end
  end
end
