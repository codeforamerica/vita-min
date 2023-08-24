module Ctc
  module Questions
    class LegalConsentController < QuestionsController
      include AnonymousIntakeConcern
      include Ctc::CanBeginIntakeConcern
      include Ctc::ResetToStartIfIntakeNotPersistedConcern
      include RecaptchaScoreConcern

      layout "intake"

      def form_params
        super.merge(recaptcha_score_param('legal_consent'))
      end

      private

      def after_update_success
        send_mixpanel_event(event_name: "ctc_provided_personal_info")
        unless current_intake.has_duplicate?
          if current_intake.primary_consented_to_service_at.blank?
            current_intake.update(
              primary_consented_to_service_ip: request.remote_ip,
              primary_consented_to_service: "yes"
            )
          end
        end
      end

      def next_path
        current_intake.has_duplicate? ? questions_returning_client_path : super
      end

      def illustration_path; end
    end
  end
end
