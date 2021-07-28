module Ctc
  module Questions
    class StimulusReceivedController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"

      def self.show?(intake)
        return false if intake.eip1_amount_received.nil? || intake.eip2_amount_received.nil?

        intake.tax_return(2020).outstanding_recovery_rebate_credit <= 0
      end

      def edit
        @first_stimulus_amount = current_intake.tax_return(2020).expected_recovery_rebate_credit_one
        @second_stimulus_amount = current_intake.tax_return(2020).expected_recovery_rebate_credit_two
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
