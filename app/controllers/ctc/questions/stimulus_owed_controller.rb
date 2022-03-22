module Ctc
  module Questions
    class StimulusOwedController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"

      def self.show?(intake)
        return false if intake.eip1_amount_received.nil? || intake.eip2_amount_received.nil?
        return false if intake.eip1_entry_method_calculated_amount?

        (Efile::BenefitsEligibility.new(tax_return: intake.default_tax_return, dependents: intake.dependents).outstanding_recovery_rebate_credit || 0) > 0
      end

      def edit
        @outstanding_credit = Efile::BenefitsEligibility.new(tax_return: current_intake.default_tax_return, dependents: current_intake.dependents).outstanding_recovery_rebate_credit
        super
      end

      private

      def illustration_path; end
    end
  end
end
