module Ctc
  module Questions
    class EmailVerificationController < QuestionsController
      include AnonymousIntakeConcern
      include Ctc::CanBeginIntakeConcern
      before_action :redirect_if_duplicate_ctc_client
      before_action :send_verification_code, only: [:edit]

      layout "intake"

      # if the client already has a valid intake with same info, don't have them verify again.
      def self.show?(intake)
        return false if intake.sms_phone_number_verified_at? # only require one verified contact type

        intake.email_address.present? && intake.email_notification_opt_in_yes? && intake.email_address_verified_at.present?
      end

      def self.i18n_base_path
        "views.ctc.questions.verification"
      end

      def after_update_success
        send_mixpanel_event(event_name: "ctc_contact_verified")
        sign_in current_intake.client

        ClientMessagingService.send_system_message_to_all_opted_in_contact_methods(
          client: current_intake.client,
          message: AutomatedMessage::CtcGettingStarted.new,
          locale: current_intake.locale
        )
      end

      private

      def send_verification_code
        RequestVerificationCodeEmailJob.perform_later(
          client_id: current_intake.client_id,
          email_address: current_intake.email_address,
          locale: I18n.locale,
          visitor_id: current_intake.visitor_id,
          service_type: :ctc
        )
      end

      def illustration_path
        "contact-preference.svg"
      end
    end
  end
end
