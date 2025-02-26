module StateFile
  module Questions
    class AzRetirementIncomeSubtractionController < RetirementIncomeSubtractionController

      def self.show?(intake)
        Flipper.enabled?(:show_retirement_ui) && has_eligible_1099rs?(intake)
      end

      def self.has_eligible_1099rs?(intake)
        intake.state_file1099_rs.any? do |form1099r|
          form1099r.taxable_amount&.to_f&.positive?
        end
      end

      private

      def eligible_1099rs
        @eligible_1099rs ||= current_intake.state_file1099_rs.select do |form1099r|
          form1099r.taxable_amount&.to_f&.positive?
        end
      end

      def num_items
        eligible_1099rs.count
      end

      def load_item(index)
        @state_file_1099r = eligible_1099rs[index]
        render "public_pages/page_not_found", status: 404 if @state_file_1099r.nil?
      end
      def followup_class = StateFileAz1099RFollowup
    end
  end
end
