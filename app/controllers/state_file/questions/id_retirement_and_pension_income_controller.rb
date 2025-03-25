module StateFile
  module Questions
    class IdRetirementAndPensionIncomeController < RetirementIncomeSubtractionController
      def self.show?(intake)
        super && !intake.filing_status_mfs?
      end

      def edit
        super
        current_intake.update(clicked_to_file_with_other_service_at: nil)
      end

      private
      def index_increment
        0
      end

      def prev_question_controller_class
        IdIneligibleRetirementAndPensionIncomeController
      end

      def next_question_controller_class
        IdIneligibleRetirementAndPensionIncomeController
      end

      def review_all_items_before_returning_to_review
        true
      end

      def followup_class = StateFileId1099RFollowup
    end
  end
end