module Ctc
  module Questions
    class AdvanceCtcController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"

      def self.show?(intake)
        intake.dependents.count(&:qualifying_ctc?).positive?
      end

      def edit
        tax_return = current_intake.default_tax_return
        benefits = Efile::BenefitsEligibility.new(tax_return: tax_return, dependents: current_intake.dependents)
        @adv_ctc_estimate = benefits.ctc_amount / 2
        super
      end

      private

      def illustration_path
        "hand-holding-cash-and-check.svg"
      end
    end
  end
end
