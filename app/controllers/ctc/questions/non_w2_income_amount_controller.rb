module Ctc
  module Questions
    class NonW2IncomeAmountController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"

      def self.show?(intake)
        true
        # eitc and you said yes on the previous page (and maybe also that money range thing, again)
      end

      private

      def illustration_path
        "hand-holding-cash-and-check.svg"
      end
    end
  end
end
