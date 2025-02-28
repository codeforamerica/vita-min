module StateFile
  module Questions
    class IdRetirementAndPensionIncomeController < RetirementIncomeSubtractionController
      def self.show?(intake)
        Flipper.enabled?(:show_retirement_ui) && !intake.filing_status_mfs? && intake.eligible_1099rs.any?
      end

      private

      def num_items
        current_intake.eligible_1099rs.count
      end

      def load_item(index)
        @eligible_1099rs ||= current_intake.eligible_1099rs
        @state_file_1099r = @eligible_1099rs[index]
        render "public_pages/page_not_found", status: 404 if @state_file_1099r.nil?
      end

      def review_all_items_before_returning_to_review
        true
      end

      def followup_class = StateFileId1099RFollowup
    end
  end
end