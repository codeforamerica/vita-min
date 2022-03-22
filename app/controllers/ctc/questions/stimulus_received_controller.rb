module Ctc
  module Questions
    class StimulusReceivedController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"

      def self.show?(intake)
        return false if intake.eip3_amount_received.nil?

        Efile::BenefitsEligibility.new(tax_return: intake.default_tax_return, dependents: intake.dependents).outstanding_recovery_rebate_credit&.zero?
      end

      def edit
        @benefits = Efile::BenefitsEligibility.new(tax_return: current_intake.default_tax_return, dependents: current_intake.dependents)
        @third_stimulus_amount = @benefits.eip3_amount
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
