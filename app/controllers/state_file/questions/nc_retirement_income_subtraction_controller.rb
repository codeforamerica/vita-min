module StateFile
  module Questions
    class NcRetirementIncomeSubtractionController < QuestionsController

      def edit
        @state_file_1099r = current_intake.state_file1099_rs[0]
        @form = NcRetirementIncomeSubtractionForm.new()
      end
    end
  end
end
