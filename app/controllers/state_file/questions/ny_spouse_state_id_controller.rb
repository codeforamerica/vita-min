module StateFile
  module Questions
    class NySpouseStateIdController < AuthenticatedQuestionsController
      include ReturnToReviewConcern

      def self.show?(intake)
        intake.filing_status_mfj?
      end
    end
  end
end
