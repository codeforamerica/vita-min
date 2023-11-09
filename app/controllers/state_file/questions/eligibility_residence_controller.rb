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
        case params[:us_state]
        when 'az'
          "state_file_az_eligibility_residence_form"
        when 'ny'
          "state_file_ny_eligibility_residence_form"
        end
      end
    end
  end
end