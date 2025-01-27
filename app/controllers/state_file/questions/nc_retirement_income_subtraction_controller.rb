module StateFile
  module Questions
    class NcRetirementIncomeSubtractionController < QuestionsController
      skip_before_action :redirect_if_no_intake, :require_state_file_intake_login

      def edit
        @state_file_1099r = current_intake.state_file1099_rs[0]
        @form = NcRetirementIncomeSubtractionForm.new()
      end
    end
  end
end
