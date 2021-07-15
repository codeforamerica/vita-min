module Ctc
  module Questions
    class FilingStatusController < QuestionsController
      include AnonymousIntakeConcern

      private

      def illustration_path
        "marital-status.svg"
      end

    end
  end
end