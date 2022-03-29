module Ctc
  module Questions
    class StimulusReceivedController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"

      def self.show?(intake)
        return false if intake.eip3_amount_received.nil?

        Efile::BenefitsEligibility.new(tax_return: intake.default_tax_return, dependents: intake.dependents).outstanding_recovery_rebate_credit&.zero?
      end

      private

      def form_class
        NullForm
      end

      def illustration_path; end
    end
  end
end
