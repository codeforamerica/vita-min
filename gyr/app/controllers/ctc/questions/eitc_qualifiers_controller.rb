module Ctc
  module Questions
    class EitcQualifiersController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"

      def self.show?(intake, current_controller)
        benefits_eligibility = Efile::BenefitsEligibility.new(tax_return: intake.default_tax_return, dependents: intake.dependents)
        current_controller.open_for_eitc_intake? &&
          intake.exceeded_investment_income_limit_no? &&
          benefits_eligibility.filers_younger_than_twenty_four? &&
          intake.dependents.none?(&:qualifying_eitc?)
      end

      private

      def illustration_path; end
    end
  end
end
