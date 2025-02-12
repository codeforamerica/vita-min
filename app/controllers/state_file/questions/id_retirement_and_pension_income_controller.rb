module StateFile
  module Questions
    class IdRetirementAndPensionIncomeController < RetirementIncomeSubtractionController
      def followup_class = StateFileId1099RFollowup
    end
  end
end