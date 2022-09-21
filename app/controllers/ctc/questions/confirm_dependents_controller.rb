module Ctc
  module Questions
    class ConfirmDependentsController < QuestionsController
      before_action :load_eligibility
      include AuthenticatedCtcClientConcern

      layout "intake"

      def self.show?(intake)
        intake.had_dependents_yes? || intake.dependents.count > 0
      end

      private

      def form_class
        NullForm
      end

      def illustration_path; end

      def load_eligibility
        @benefits_eligibility = Efile::BenefitsEligibility.new(tax_return: current_intake.default_tax_return, dependents: current_intake.dependents)
      end
    end
  end
end
