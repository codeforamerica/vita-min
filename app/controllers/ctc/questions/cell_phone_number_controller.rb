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
          phone_number: @form.sms_phone_number,
          locale: I18n.locale,
          visitor_id: current_intake.visitor_id,
          client_id: current_intake.client_id,
          service_type: :ctc
        )
      end

      def next_path
        questions_consent_path #TODO: should redirect to verify-identity
      end

      def prev_path
        questions_contact_preference_path
      end

      def illustration_path
        "phone-number.svg"
      end
    end
  end
end