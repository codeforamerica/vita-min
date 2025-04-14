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

      def edit
        current_intake.update(clicked_to_file_with_other_service_at: nil)
        super
      end

      def file_with_another_service
        load_links
        current_intake.touch(:clicked_to_file_with_other_service_at)
      end

      def continue_filing_path
        url_options = { action: :edit, item_index: item_index }
        url_options.merge!(
          {
            return_to_review: params[:return_to_review],
            return_to_review_before: params[:return_to_review_before],
            return_to_review_after: params[:return_to_review_after]
          }.compact
        )
        self.class.to_path_helper(url_options)
      end
      helper_method :continue_filing_path

      private

      def followup_class = StateFileId1099RFollowup
    end
  end
end