module StateFile
  module Questions
    class NjEstimatedTaxPaymentsController < QuestionsController
      include ReturnToReviewConcern

      def prev_path
        NjHouseholdRentOwnController.to_path_helper
      end
    end
  end
end
