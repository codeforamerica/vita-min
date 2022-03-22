module Ctc
  module Questions
    class StimulusReceivedController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"

      def self.show?(intake)
        return false if intake.eip1_amount_received.nil? || intake.eip2_amount_received.nil?

        Efile::BenefitsEligibility.new(tax_return: intake.default_tax_return, dependents: intake.dependents).outstanding_recovery_rebate_credit&.zero?
      end

      def edit
        @benefits = Efile::BenefitsEligibility.new(tax_return: current_intake.default_tax_return, dependents: current_intake.dependents)
        @first_stimulus_amount = @benefits.eip1_amount
        @second_stimulus_amount = @benefits.eip2_amount
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
