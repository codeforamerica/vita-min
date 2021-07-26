module Ctc
  module Questions
    class StimulusPaymentsController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"

      def edit
        @first_stimulus_amount = current_intake.tax_return(2020).expected_recovery_rebate_credit_one
        @second_stimulus_amount = current_intake.tax_return(2020).expected_recovery_rebate_credit_two
        super
      end

      def next_path
        questions_stimulus_received_path
      end

      private

      def illustration_path
        "hand-holding-check.svg"
      end
    end
  end
end