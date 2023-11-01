module StateFile
  module Questions
    class AzSeniorDependentsController < QuestionsController
      def self.show?(intake)
        intake.dependents.az_qualifying_senior.exists?
      end

      private

      def form_params
        permitted_attributes = []
        dependents_attributes = [:id, :needed_assistance, :passed_away]
        params.require(:state_file_az_senior_dependents_form).permit(permitted_attributes + [{ dependents_attributes: dependents_attributes }])
      end
    end
  end
end
