module StateFile
  module Questions
    class AzRetirementIncomeSubtractionController < RetirementIncomeSubtractionController
      include ReturnToReviewConcern

      def followup_class = StateFileAz1099RFollowup
    end
  end
end
