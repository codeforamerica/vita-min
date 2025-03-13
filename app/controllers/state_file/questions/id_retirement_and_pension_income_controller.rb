module StateFile
  module Questions
    class IdRetirementAndPensionIncomeController < RetirementIncomeSubtractionController
      def self.show?(intake)
        super && !intake.filing_status_mfs?
      end

      private

      def index_increment
        0
      end

      def prev_question_controller_class
        IdRetirementSecondController
      end

      def next_question_controller_class
        # if @state_file_1099r.has_some_condition
          IdRetirementSecondController
        # else
        #   super
        # end
      end

      def review_all_items_before_returning_to_review
        true
      end

      def followup_class = StateFileId1099RFollowup
    end
  end
end