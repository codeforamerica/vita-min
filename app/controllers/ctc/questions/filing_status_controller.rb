module Ctc
  module Questions
    class FilingStatusController < QuestionsController
      include AnonymousIntakeConcern
      include FirstPageOfCtcIntakeConcern

      private

      def illustration_path
        "marital-status.svg"
      end
    end
  end
end