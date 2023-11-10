module StateFile
  module Questions
    class EligibilityResidenceController < QuestionsController
      include StartIntakeConcern

      def form_class
        case params[:us_state]
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