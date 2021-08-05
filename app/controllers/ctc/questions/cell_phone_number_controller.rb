module Ctc
  module Questions
    class CellPhoneNumberController < QuestionsController
      include AnonymousIntakeConcern

      layout "intake"

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
