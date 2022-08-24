module Ctc
  module Questions
    class ConfirmW2sController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"

      def self.show?(intake)
        return unless Flipper.enabled?(:eitc)

        benefits_eligibility = Efile::BenefitsEligibility.new(tax_return: intake.default_tax_return, dependents: intake.dependents)
        benefits_eligibility.claiming_and_qualified_for_eitc?
      end

      def edit
        render 'ctc/questions/w2s/edit'
      end

      def self.form_class
        NullForm
      end

      private

      def illustration_path; end
    end
  end
end
