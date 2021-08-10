module Ctc
  module Questions
    class LegalConsentController < QuestionsController
      include FirstQuestionConcern
      include AnonymousIntakeConcern
      include Ctc::CanBeginIntakeConcern
      layout "intake"

      def form_params
        super.merge(ip_address: request.remote_ip)
      end

      private

      def after_update_success
        send_mixpanel_event(event_name: "ctc_provided_personal_info")
      end

      def illustration_path; end
    end
  end
end
