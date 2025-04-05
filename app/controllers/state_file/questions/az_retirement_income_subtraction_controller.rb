module StateFile
  module Questions
    class AzRetirementIncomeSubtractionController < RetirementIncomeSubtractionController

      def followup_class = StateFileAz1099RFollowup
    end
  end
end
