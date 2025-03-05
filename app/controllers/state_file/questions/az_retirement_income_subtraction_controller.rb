module StateFile
  module Questions
    class AzRetirementIncomeSubtractionController < RetirementIncomeSubtractionController
      include ReturnToReviewConcern

      def self.show?(intake)
        Flipper.enabled?(:show_retirement_ui) && intake.eligible_1099rs.present?
      end

      def followup_class = StateFileAz1099RFollowup
    end
  end
end
