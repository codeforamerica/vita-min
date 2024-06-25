module StateFile
  module Questions
    class EligibilityOutOfStateIncomeController < QuestionsController
      include EligibilityOffboardingConcern

      def form_class
        "StateFile::#{current_state_code.capitalize}EligibilityOutOfStateIncomeForm".constantize
      end

      def form_name
        form_class.to_s.underscore.gsub("/", "_")
      end
    end
  end
end