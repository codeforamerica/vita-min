module Ctc
  module Questions
    class LegalConsentController < QuestionsController
      include FirstQuestionConcern
      include AnonymousIntakeConcern
      include Ctc::CanBeginIntakeConcern
      layout "intake"

      def form_params
        super.merge(ip_address: request.remote_ip).merge(
          Rails.application.config.efile_security_information_for_testing.presence || {}
        )
      end

      private

      def after_update_success
        send_mixpanel_event(event_name: "ctc_provided_personal_info")
      end

      def after_update_failure
        if Set.new(@form.errors.keys).intersect?(Set.new(@form.class.scoped_attributes[:efile_security_information]))
          flash[:alert] = I18n.t("general.enable_javascript")
        end
      end

      def illustration_path; end
    end
  end
end
