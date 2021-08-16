module Ctc
  module Questions
    class LegalConsentController < QuestionsController
      include AnonymousIntakeConcern
      include Ctc::CanBeginIntakeConcern
      include Ctc::ResetToStartIfIntakeNotPersistedConcern

      layout "intake"

      private

      def after_update_success
        send_mixpanel_event(event_name: "ctc_provided_personal_info")
      end

      def illustration_path; end
    end
  end
end
