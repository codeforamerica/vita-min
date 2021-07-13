module Ctc
  module Questions
    class StimulusOneController < QuestionsController
      # TODO: Transition to Authenticated once we log in client
      include AnonymousIntakeConcern

      layout "intake"

      def update
        current_intake.update!(eip_one: 0)
        # TODO: redirect to stimulus-2
        redirect_to questions_placeholder_question_path
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