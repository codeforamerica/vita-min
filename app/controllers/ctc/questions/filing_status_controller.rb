module Ctc
  module Questions
    class FilingStatusController < QuestionsController
      include AnonymousIntakeConcern

      private

      def illustration_path; end

    end
  end
end