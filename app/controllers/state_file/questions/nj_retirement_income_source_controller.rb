module StateFile
  module Questions
    class NjRetirementIncomeSourceController < RetirementIncomeSubtractionController
      def followup_class = StateFileNc1099RFollowup

      def self.show?(intake, item_index: nil)
        Flipper.enabled?(:show_retirement_ui) && intake.state_file1099_rs.length.positive?
      end

      def self.load_1099r(intake, index)
        intake.state_file1099_rs[index]
      end
    end
  end
end

