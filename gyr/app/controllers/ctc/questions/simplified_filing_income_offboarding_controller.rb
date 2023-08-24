module Ctc
  module Questions
    class SimplifiedFilingIncomeOffboardingController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"

      def self.show?(intake, current_controller)
        return false unless current_controller.open_for_eitc_intake?

        intake.benefits_eligibility.disqualified_for_simplified_filing_due_to_income?
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
