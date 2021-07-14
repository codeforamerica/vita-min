module Ctc
  module Questions
    class StimulusTwoReceivedController < QuestionsController
      # TODO: Transition to Authenticated once we log in client
      include AnonymousIntakeConcern

      layout "intake"

      private

      def illustration_path
        "hand-holding-cash-and-check.svg"
      end
    end
  end
end