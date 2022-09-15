module Ctc
  module Questions
    class NonW2IncomeController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "yes_no_question"

      def self.show?(intake)
        return false unless Flipper.enabled?(:eitc)

        if intake.filing_jointly?
          (15_000...17_549).cover?(intake.total_wages_amount)
        else
          (10_000...11_609).cover?(intake.total_wages_amount)
        end
      end

      private

      def method_name
        'had_disqualifying_non_w2_income'
      end

      def illustration_path
        "hand-holding-cash-and-check.svg"
      end
    end
  end
end
