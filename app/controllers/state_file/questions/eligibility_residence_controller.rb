module StateFile
  module Questions
    class EligibilityResidenceController < QuestionsController
      include EligibilityOffboardingConcern

      def form_class
        "StateFile::#{current_state_code.capitalize}EligibilityResidenceForm".constantize
      end

      def form_name
        form_class.to_s.underscore.gsub("/", "_")
      end
    end
  end
end