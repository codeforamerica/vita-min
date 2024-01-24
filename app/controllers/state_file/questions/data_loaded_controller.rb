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