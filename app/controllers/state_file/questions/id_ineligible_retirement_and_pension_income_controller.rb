module StateFile
  module Questions
    class IdIneligibleRetirementAndPensionIncomeController < RetirementIncomeSubtractionController
      include OtherOptionsLinksConcern
      def self.show?(intake, item_index: nil)
        return false unless item_index.present?
        state_file_1099r = load_1099r(intake, item_index)
        super &&
          !intake.filing_status_mfs? &&
          state_file_1099r&.state_specific_followup&.civil_service_account_number_eight?
      end

      def file_with_another_service
        load_links
        current_intake.touch(:clicked_to_file_with_other_service_at)
      end

      def continue_filing
        current_intake.update(clicked_to_file_with_other_service_at: nil)
        redirect_to next_path
      end

      private

      def followup_class = StateFileId1099RFollowup
    end
  end
end