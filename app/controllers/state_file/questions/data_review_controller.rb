module StateFile
  module Questions
    class DataReviewController < QuestionsController
      def edit
        super
        StateFileEfileDeviceInfo.find_or_create_by!(
          event_type: "initial_creation",
          ip_address: ip_for_irs,
          intake: current_intake,
        )
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
