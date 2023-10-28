module StateFile
  module Questions
    class DobController < QuestionsController
      private

      def form_params
        params.require(:state_file_dob_form).permit(dependents_attributes: [:id, :dob_month, :dob_day, :dob_year, :months_in_home])
      end
    end
  end
end
