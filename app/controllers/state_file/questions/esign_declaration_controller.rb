module StateFile
  module Questions
    class EsignDeclarationController < AuthenticatedQuestionsController
      def edit
        super
        StateFileEfileDeviceInfo.find_or_create_by!(
          event_type: "submission",
          ip_address: ip_for_irs,
          intake: current_intake,
          )
      end

      def update
        @form = initialized_update_form
        if form_params["device_id"].blank?
          flash[:alert] = I18n.t("general.enable_javascript")
          render :edit
        else
          flash.clear
          super
        end
      end


      private

      def card_postscript; end

    end
  end
end
