module Ctc
  module Questions
    class NonW2IncomeController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "yes_no_question"

      def self.show?(intake)
        "eitc and income in specific range"
      end

      def edit
      end

      private

      def illustration_path
        "hand-holding-cash-and-check.svg"
      end
    end
  end
end
