module Ctc
  module Questions
    class VerificationController < QuestionsController
      # TODO: Transition to Authenticated once we log in client
      include AnonymousIntakeConcern

      layout "intake"

      private

      def illustration_path
        "contact-preference.svg"
      end
    end
  end
end