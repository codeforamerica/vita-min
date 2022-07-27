module Ctc
  module Questions
    class EitcOffboardingController < QuestionsController
      include AuthenticatedCtcClientConcern

      # Add this question to the right place in the flow inside of the CtcQuestionNavigationFlow
      layout "intake"

      # Only show this if eitc feature is enabled AND the client answered yes to exceeded_investment_income_limit
      # intake.exceeded_investment_income_limit_yes?
      def self.show?(intake)
        Flipper.enabled?(:eitc) && intake.claim_eitc_yes? && intake.exceeded_investment_income_limit_yes?
      end

      private

      # swap this out for the correct icon
      def illustration_path
        "error.svg"
      end

      def form_class
        NullForm
      end
    end
  end
end