module StateFile
  module Questions
    class NcSpouseStateIdController < QuestionsController
      include ReturnToReviewConcern

      def self.show?(intake)
        intake.filing_status_mfj?
      end
    end
  end
end
