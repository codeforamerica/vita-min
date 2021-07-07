module Ctc
  module Questions
    class CellPhoneNumberController < QuestionsController
      include AnonymousIntakeConcern

      layout "intake"

      def update
        super
      end

      private

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