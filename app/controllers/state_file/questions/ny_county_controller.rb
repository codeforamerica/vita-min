require 'csv'

module StateFile
  module Questions
    class NyCountyController < AuthenticatedQuestionsController
      include ReturnToReviewConcern

      private

      def illustration_path; end
    end
  end
end
