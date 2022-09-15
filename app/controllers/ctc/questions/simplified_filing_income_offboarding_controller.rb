module Ctc
  module Questions
    class SimplifiedFilingIncomeOffboardingController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"

      def self.show?(intake)
        return false unless Flipper.enabled?(:eitc)
        return false unless intake.total_wages_amount

        if intake.filing_jointly?
          intake.total_wages_amount > 25_100
        else
          intake.total_wages_amount > 12_550
        end
      end

      private

      def illustration_path
        "error.svg"
      end

      def form_class
        NullForm
      end
    end
  end
end