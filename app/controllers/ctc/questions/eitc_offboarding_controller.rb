module Ctc
  module Questions
    class EitcOffboardingController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"

      def self.show?(intake)
        Flipper.enabled?(:eitc) && intake.claim_eitc_yes? && intake.exceeded_investment_income_limit_yes?
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