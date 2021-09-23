module Ctc
  module Questions
    class ConfirmLegalController < QuestionsController
      include AuthenticatedCtcClientConcern
      include RecaptchaScoreConcern

      layout "intake"

      def form_params
        params = super.merge(ip_address: request.remote_ip).merge(
          Rails.application.config.try(:efile_security_information_for_testing).presence || {}
        )
        params.merge(recaptcha_score_param('confirm_legal'))
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
