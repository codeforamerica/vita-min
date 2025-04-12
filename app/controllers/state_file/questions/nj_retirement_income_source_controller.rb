module StateFile
  module Questions
    class NjRetirementIncomeSourceController < RetirementIncomeSubtractionController
      def followup_class = StateFileNj1099RFollowup
    end
  end
end

