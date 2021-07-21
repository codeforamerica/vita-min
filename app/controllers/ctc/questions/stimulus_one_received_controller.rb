module Ctc
  module Questions
    class StimulusOneReceivedController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"

      private

      def illustration_path
        "hand-holding-check.svg"
      end
    end
  end
end