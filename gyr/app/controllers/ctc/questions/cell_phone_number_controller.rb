module Ctc
  module Questions
    class CellPhoneNumberController < QuestionsController
      include AnonymousIntakeConcern

      layout "intake"

      def after_update_success
        if current_intake.sms_notification_opt_in_yes?
          ClientMessagingService.send_system_text_message(
            client: current_intake.client,
            body: I18n.t("messages.ctc_sms_opt_in"),
            to: current_intake.sms_phone_number
          )
        end
      end

      private

      def illustration_path
        "phone-number.svg"
      end

      def prev_path
        questions_contact_preference_path
      end

      def next_path
        questions_phone_verification_path
      end
    end
  end
end
