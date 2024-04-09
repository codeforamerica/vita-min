module StateFile
  module Questions
    class NameDobController < AuthenticatedQuestionsController
      include ReturnToReviewConcern

      def edit
        @over_65 = current_intake.direct_file_data.node.at("Primary65OrOlderInd")&.content == "X"
        if current_intake.state_file_analytics.name_dob_first_visit_at.nil?
          current_intake.state_file_analytics.update!(name_dob_first_visit_at: DateTime.now)
        end
        super
      end

      private

      def form_params
        permitted_attributes = [:primary_first_name, :primary_middle_initial, :primary_last_name, :primary_suffix, :device_id]
        permitted_attributes.concat([:primary_birth_date_month, :primary_birth_date_day, :primary_birth_date_year])
        permitted_attributes.concat([:spouse_first_name, :spouse_middle_initial, :spouse_last_name, :spouse_suffix]) if current_intake.ask_spouse_name?
        permitted_attributes.concat([:spouse_birth_date_month, :spouse_birth_date_day, :spouse_birth_date_year]) if current_intake.ask_spouse_dob?

        dependents_attributes = [:id, :first_name, :last_name, :dob_month, :dob_day, :dob_year]
        dependents_attributes << :months_in_home if current_intake.ask_months_in_home?

        params.require(:state_file_name_dob_form).permit(permitted_attributes + [{ dependents_attributes: dependents_attributes }])
      end
    end
  end
end
