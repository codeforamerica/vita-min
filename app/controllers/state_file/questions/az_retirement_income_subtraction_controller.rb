module StateFile
  module Questions
    class AzRetirementIncomeSubtractionController < RetirementIncomeSubtractionController

      def self.show?(intake)
        binding.pry
        Flipper.enabled?(:show_retirement_ui) && intake.eligible_1099rs.present?
      end

      def eligible_1099rs
        @eligible_1099rs ||= current_intake.state_file1099_rs.select do |form1099r|
          form1099r.taxable_amount&.to_f&.positive?
        end
      end

      def followup_class = StateFileAz1099RFollowup
    end
  end
end
