module Ctc
  module Questions
    class EitcOffboardingController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"

      def self.show?(intake)
        benefits_eligibility = Efile::BenefitsEligibility.new(tax_return: intake.default_tax_return, dependents: intake.dependents)
        intake.claiming_eitc? && !benefits_eligibility.qualified_for_eitc?
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