module Ctc
  module Questions
    class StimulusThreeController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"

      def edit
        tax_return = current_intake.default_tax_return
        benefits = Efile::BenefitsEligibility.new(tax_return: tax_return, dependents: current_intake.dependents)
        @first_stimulus_amount = benefits.eip1_amount
        @second_stimulus_amount = benefits.eip2_amount
        super
      end

      private

      def illustration_path
        "hand-holding-check.svg"
      end
    end
  end
end
