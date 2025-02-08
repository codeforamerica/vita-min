module StateFile
  module Questions
    class NcRetirementIncomeSubtractionController < RetirementIncomeSubtractionController
      def followup_class = StateFileNc1099RFollowup
    end
  end
end
