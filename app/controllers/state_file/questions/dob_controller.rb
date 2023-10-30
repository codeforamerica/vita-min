module StateFile
  module Questions
    class DobController < QuestionsController
      private

      def form_params
        permitted_attributes = []
        permitted_attributes.concat([:primary_birth_date_month, :primary_birth_date_day, :primary_birth_date_year]) if current_intake.ask_primary_dob?
        permitted_attributes.concat([:spouse_birth_date_month, :spouse_birth_date_day, :spouse_birth_date_year]) if current_intake.ask_primary_dob?

        dependents_attributes = [:id, :dob_month, :dob_day, :dob_year]
        dependents_attributes << :months_in_home if current_intake.ask_months_in_home?

        params.require(:state_file_dob_form).permit(permitted_attributes + [{ dependents_attributes: dependents_attributes }])
      end
    end
  end
end
