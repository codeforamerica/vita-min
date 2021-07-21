module Ctc
  module Questions
    class StimulusTwoController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"

      def update
        current_intake.update!(recovery_rebate_credit_amount_2: 0)
        # TODO: redirect to either stimulus received or owed based on whether provided sum is greater than calculated
        redirect_to questions_stimulus_received_path
      end

      private

      def form_class
        NullForm
      end

      def illustration_path
        "hand-holding-cash-and-check.svg"
      end
    end
  end
end