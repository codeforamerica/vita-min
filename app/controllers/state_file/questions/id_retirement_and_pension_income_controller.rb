module StateFile
  module Questions
    class IdRetirementAndPensionIncomeController < RetirementIncomeSubtractionController
      def self.show?(intake, item_index: nil)
        super && !intake.filing_status_mfs?
      end

      def edit
        current_intake.update(clicked_to_file_with_other_service_at: nil)
        super
      end

      private

      def followup_class = StateFileId1099RFollowup
    end
  end
end