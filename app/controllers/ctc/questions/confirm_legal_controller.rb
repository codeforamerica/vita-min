module Ctc
  module Questions
    class ConfirmLegalController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"

      def form_params
        params = super.merge(ip_address: request.remote_ip).merge(
          Rails.application.config.try(:efile_security_information_for_testing).presence || {}
        )
        if verify_recaptcha(action: 'confirm_legal')
          params[:recaptcha_score] = recaptcha_reply['score']
        else
          Rails.logger.error "Failed to verify recaptcha token due to the following errors: #{recaptcha_reply["error-codes"]}"
        end
        params
      end

      private

      def after_update_success
        send_mixpanel_event(event_name: "ctc_submitted_intake")
      end

      def after_update_failure
        if Set.new(@form.errors.keys).intersect?(Set.new(@form.class.scoped_attributes[:efile_security_information]))
          flash[:alert] = I18n.t("general.enable_javascript")
        end
      end

      def next_path
        ctc_portal_root_path
      end

      def illustration_path
        "successfully-submitted.svg"
      end
    end
  end
end
