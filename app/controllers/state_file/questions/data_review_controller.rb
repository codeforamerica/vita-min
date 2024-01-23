module StateFile
  module Questions
    class DataReviewController < QuestionsController

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
