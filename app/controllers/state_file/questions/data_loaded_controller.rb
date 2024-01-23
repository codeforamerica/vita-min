module StateFile
  module Questions
    class DataLoadedController < QuestionsController
      def edit
        super
        # Redirect to offboarding here if not eligible
        if current_intake&.has_disqualifying_eligibility_answer? ||
          current_intake&.disqualifying_df_data_reason.present?
          redirect_to next_path and return
        end
        # Is there an existing intake with the same SSN?
        # We have an intake.hashed_ssn
        # current_intake.primary.ssn
        # existing_intake = current_intake.class.where.not(id: current_intake.id).where()
        # Do we need to somehow match existing here?
        StateFileEfileDeviceInfo.find_or_create_by!(
          event_type: "initial_creation",
          ip_address: ip_for_irs,
          intake: current_intake,
          )
        sign_in current_intake
        redirect_to next_path
      end
    end
  end
end