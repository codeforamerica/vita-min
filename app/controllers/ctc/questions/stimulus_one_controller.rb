module Ctc
  module Questions
    class StimulusOneController < QuestionsController
      # TODO: Transition to Authenticated once we log in client
      include AnonymousIntakeConcern

      layout "intake"

      def update
        current_intake.update!(eip_one: 0)
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