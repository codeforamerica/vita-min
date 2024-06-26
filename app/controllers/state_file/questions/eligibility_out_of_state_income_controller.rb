module StateFile
  module Questions
    class EligibilityOutOfStateIncomeController < QuestionsController
      include EligibilityOffboardingConcern

      def form_class
        case current_state_code
        when 'az'
          StateFile::AzEligibilityOutOfStateIncomeForm
        when 'ny'
          StateFile::NyEligibilityOutOfStateIncomeForm
        end
      end

      def form_name
        form_class.to_s.underscore.gsub("/", "_")
      end
    end
  end
end