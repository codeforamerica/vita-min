module Ctc
  module Questions
    class InvestmentIncomeController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "yes_no_question"

      def self.show?(intake)
        intake.claiming_eitc?
      end

      private

      def illustration_path
        "piggy-bank.svg"
      end

      def method_name
        'exceeded_investment_income_limit'
      end
    end
  end
end