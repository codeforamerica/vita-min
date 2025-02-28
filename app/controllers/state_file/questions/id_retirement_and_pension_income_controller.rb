module StateFile
  module Questions
    class IdRetirementAndPensionIncomeController < RetirementIncomeSubtractionController
      def self.show?(intake)
        Flipper.enabled?(:show_retirement_ui) && !intake.filing_status_mfs? && intake.eligible_1099rs.any?
      end

      private

      def review_all_items_before_returning_to_review
        true
      end

      def followup_class = StateFileId1099RFollowup
    end
  end
end