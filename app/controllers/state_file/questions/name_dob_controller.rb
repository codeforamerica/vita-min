module StateFile
  module Questions
    class NameDobController < AuthenticatedQuestionsController
      include ReturnToReviewConcern
      include StateSpecificQuestionConcern

      private

      def form_params
        permitted_attributes = [:primary_first_name, :primary_last_name]
        permitted_attributes.concat([:primary_birth_date_month, :primary_birth_date_day, :primary_birth_date_year]) if current_intake.ask_primary_dob?
        permitted_attributes.concat([:spouse_first_name, :spouse_last_name]) if current_intake.ask_spouse_name?
        permitted_attributes.concat([:spouse_birth_date_month, :spouse_birth_date_day, :spouse_birth_date_year]) if current_intake.ask_primary_dob?

        dependents_attributes = [:id, :first_name, :last_name, :dob_month, :dob_day, :dob_year]
        dependents_attributes << :months_in_home if current_intake.ask_months_in_home?

        params.require(:state_file_name_dob_form).permit(permitted_attributes + [{ dependents_attributes: dependents_attributes }])
      end
    end
  end
end
