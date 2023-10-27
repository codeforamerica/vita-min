module StateFile
  module Questions
    class AzDependentsDobController < QuestionsController
      layout "state_file/question"

      def illustration_path; end

      private

      def form_params
        params.require(:state_file_az_dependents_dob_form).permit(dependents_attributes: [:id, :dob_month, :dob_day, :dob_year, :months_in_home])
      end
    end
  end
end
