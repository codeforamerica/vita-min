module Ctc
  module Questions
    class StimulusTwoReceivedController < QuestionsController
      # TODO: Transition to Authenticated once we log in client
      include AnonymousIntakeConcern

      layout "intake"

      def update
        super
        # TODO: redirect to either stimulus received or owed based on whether provided sum is greater than calculated
      end

      private

      def illustration_path
        "hand-holding-cash-and-check.svg"
      end
    end
  end
end