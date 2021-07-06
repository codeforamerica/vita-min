module Ctc
  module Questions
    class CellPhoneNumberController < QuestionsController
      include AnonymousIntakeConcern

      layout "intake"

      def update
        super
      end

      private

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