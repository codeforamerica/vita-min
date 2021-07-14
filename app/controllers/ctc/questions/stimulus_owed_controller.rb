module Ctc
  module Questions
    class StimulusOwedController < QuestionsController
      # TODO: Transition to Authenticated once we log in client
      include AnonymousIntakeConcern

      layout "intake"

      private

      def illustration_path; end
    end
  end
end