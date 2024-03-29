module Ctc
  module Questions
    class EitcOffboardingController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"

      def self.show?(intake, current_controller)
        benefits_eligibility = Efile::BenefitsEligibility.new(tax_return: intake.default_tax_return, dependents: intake.dependents)
        current_controller.open_for_eitc_intake? && intake.claim_eitc_yes? && !benefits_eligibility.qualified_for_eitc_pre_w2s?
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
