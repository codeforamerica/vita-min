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
      end

      def illustration_path; end
    end
  end
end
