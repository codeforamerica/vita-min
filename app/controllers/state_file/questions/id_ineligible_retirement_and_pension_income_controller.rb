module StateFile
  module Questions
    class IdIneligibleRetirementAndPensionIncomeController < RetirementIncomeSubtractionController

      private

      def followup_class = StateFileId1099RFollowup
    end
  end
end