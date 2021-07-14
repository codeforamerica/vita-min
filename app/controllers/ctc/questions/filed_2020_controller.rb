module Ctc
  module Questions
    class Filed2020Controller < QuestionsController
      # TODO: Transition to Authenticated once we log in client
      include AnonymousIntakeConcern

      layout "yes_no_question"

      private

      def illustration_path
        "hand-holding-check.svg"
      end
    end
  end
end