module StateFile
  module Questions
    class DataReviewController < QuestionsController
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
      end

      def update
        if form_params["device_id"].blank?
          flash[:alert] = I18n.t("general.enable_javascript")
          render :edit
        else
          flash.clear
          super
        end
      end

      private

      def prev_path
        nil
      end
    end
  end
end
