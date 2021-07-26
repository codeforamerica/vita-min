module Ctc
  module Questions
    class StimulusOneController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"

      def update
        current_intake.update!(eip1_amount_received: 0)
        redirect_to questions_stimulus_two_path
      end

      private

      def form_class
        NullForm
      end

      def illustration_path
        "hand-holding-check.svg"
      end
    end
  end
end
