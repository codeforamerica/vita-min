module Ctc
  module Questions
    class NonW2IncomeAmountController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"

      def self.show?(intake)
        Flipper.enabled?(:eitc) && 'you said yes on the previous page (and maybe also income in specific range)'
      end

      private

      def illustration_path
        "hand-holding-cash-and-check.svg"
      end
    end
  end
end
