module Ctc
  module Questions
    class StimulusTwoController < QuestionsController
      # TODO: Transition to Authenticated once we log in client
      include AnonymousIntakeConcern

      layout "intake"

      def update
        current_intake.update!(recovery_rebate_credit_amount_2: 0)
        # TODO: redirect to stimulus received or owed
        redirect_to questions_placeholder_question_path
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