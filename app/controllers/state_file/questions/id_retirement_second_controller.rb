module StateFile
  module Questions
    class IdRetirementSecondController < RetirementIncomeSubtractionController
      def self.show?(intake)
        false
      end

      private

      def index_decrement
        0
      end

      def prev_question_controller_class
        IdRetirementAndPensionIncomeController
      end

      def next_question_controller_class
        IdRetirementAndPensionIncomeController
      end

      def review_all_items_before_returning_to_review
        true
      end

      def followup_class = StateFileId1099RFollowup
    end
  end
end