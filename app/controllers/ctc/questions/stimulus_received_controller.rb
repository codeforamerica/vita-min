module Ctc
  module Questions
    class StimulusReceivedController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"

      def self.show?(intake)
        return false if intake.eip1_amount_received.nil? || intake.eip2_amount_received.nil?

        intake.default_tax_return&.outstanding_recovery_rebate_credit&.zero?
      end

      def edit
        tax_return = current_intake.default_tax_return
        @first_stimulus_amount = tax_return.expected_recovery_rebate_credit_one
        @second_stimulus_amount = tax_return.expected_recovery_rebate_credit_two
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
