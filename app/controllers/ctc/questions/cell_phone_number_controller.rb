module Ctc
  module Questions
    class CellPhoneNumberController < QuestionsController
      include AnonymousIntakeConcern

      layout "intake"

      def update
        super
      end

      private

      def after_update_success
        ClientTextMessageVerificationRequestJob.perform_later(
          sms_phone_number: @form.sms_phone_number,
          locale: I18n.locale,
          visitor_id: current_intake.visitor_id
        )
      end

      def prev_path
        questions_contact_preference_path
      end

      def next_path
        questions_placeholder_question_path # replace with verify identity path
      end

      def illustration_path
        "phone-number.svg"
      end
    end
  end
end