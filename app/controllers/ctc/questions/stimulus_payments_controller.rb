module Ctc
  module Questions
    class StimulusPaymentsController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"

      def edit
        tax_return = current_intake.default_tax_return
        benefits = Efile::BenefitsEligibility.new(tax_return: tax_return, dependents: current_intake.dependents)
        @third_stimulus_amount = benefits.eip3_amount
        super
      end

      private

      def illustration_path
        "hand-holding-check.svg"
      end
    end
  end
end
