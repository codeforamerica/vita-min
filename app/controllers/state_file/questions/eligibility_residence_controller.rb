module StateFile
  module Questions
    class EligibilityResidenceController < QuestionsController
      include EligibilityOffboardingConcern

      def form_class
        case current_state_code
        when 'az'
          StateFile::AzEligibilityResidenceForm
        when 'ny'
          StateFile::NyEligibilityResidenceForm
        end
      end

      def form_name
        form_class.to_s.underscore.gsub("/", "_")
      end
    end
  end
end