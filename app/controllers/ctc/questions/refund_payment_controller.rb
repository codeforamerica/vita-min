module Ctc
  module Questions
    class RefundPaymentController < QuestionsController
      # TODO: Transition to Authenticated once we log in client
      include AnonymousIntakeConcern

      layout "intake"

      private

      def illustration_path
        "hand-holding-check.svg"
      end
    end
  end
end