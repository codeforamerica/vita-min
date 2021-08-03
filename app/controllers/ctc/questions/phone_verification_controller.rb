module Ctc
  module Questions
    class PhoneVerificationController < QuestionsController
      include AnonymousIntakeConcern
      before_action :send_verification_code, only: [:edit]

      layout "intake"

      def self.show?(intake)
        # if the client already has a valid intake with same info, don't show
        return false if ClientLoginService.has_ctc_duplicate?(intake)
        return false if intake.email_address_verified_at? # only require one verified contact type

        # if the client has already verified the phone number, don't show
        intake.sms_phone_number.present? && intake.sms_notification_opt_in_yes? && !intake.sms_phone_number_verified_at.present?
      end

      def after_update_success
        sign_in current_intake.client
      end

      private

      def send_verification_code
        RequestVerificationCodeTextMessageJob.perform_later(
          phone_number: current_intake.sms_phone_number,
          locale: I18n.locale,
          visitor_id: current_intake.visitor_id,
          client_id: current_intake.client_id,
          service_type: :ctc
        )
      end

      def illustration_path
        "contact-preference.svg"
      end
    end
  end
end
