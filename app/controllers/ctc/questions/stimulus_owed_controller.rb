module Ctc
  module Questions
    class StimulusOwedController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"

      def self.show?(intake)
        return false if intake.eip3_amount_received.nil?

        (Efile::BenefitsEligibility.new(tax_return: intake.default_tax_return, dependents: intake.dependents).outstanding_recovery_rebate_credit || 0).positive?
      end

      def edit
        @outstanding_credit = Efile::BenefitsEligibility.new(tax_return: current_intake.default_tax_return, dependents: current_intake.dependents).outstanding_recovery_rebate_credit
        super
      end

      private

      def form_class
        NullForm
      end

      def illustration_path; end
    end
  end
end
