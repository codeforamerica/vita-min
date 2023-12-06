module StateFile
  module Questions
    class AzSeniorDependentsController < AuthenticatedQuestionsController
      def self.show?(intake)
        intake.dependents.az_qualifying_senior.exists?
      end

      private

      def form_params
        params.require(:state_file_az_senior_dependents_form).permit([{ dependents_attributes: [:id, :needed_assistance, :passed_away] }])
      end
    end
  end
end
