module StateFile
  module Questions
    class EligibilityOutOfStateIncomeController < QuestionsController
      include EligibilityOffboardingConcern

      def form_class
        "StateFile::#{params[:us_state].capitalize}EligibilityOutOfStateIncomeForm".constantize
      end

      def form_name
        form_class.to_s.underscore.gsub("/", "_")
      end
    end
  end
end