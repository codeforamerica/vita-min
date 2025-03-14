module StateFile
  module Questions
    class IdIneligibleRetirementAndPensionIncomeController < RetirementIncomeSubtractionController
      def self.show?(intake)
        false
      end

      def edit
        unless @state_file_1099r.state_specific_followup.civil_service_account_number_eight?
          redirect_to next_path and return
        end
        super
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