module StateFile
  module Questions
    class MdRetirementIncomeSubtractionController < RetirementIncomeSubtractionController

      def self.show?(intake)
        Flipper.enabled?(:show_retirement_ui) && intake.eligible_1099rs.present?
      end

      def followup_class = StateFileMd1099RFollowup
    end
  end
end
