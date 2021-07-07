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
        RequestVerificationCodeTextMessageJob.perform_later(
            sms_phone_number: @form.sms_phone_number,
          locale: I18n.locale,
          visitor_id: current_intake.visitor_id,
          client_id: current_intake.client_id,
          verification_type: :ctc_intake
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