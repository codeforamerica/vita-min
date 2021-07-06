module Ctc
  module Questions
    class EmailAddressController < QuestionsController
      include AnonymousIntakeConcern

      layout "intake"

      private

      def prev_path
        questions_contact_preference_path
      end

      def next_path
        questions_placeholder_question_path # replace with verify identity path
      end
    end
  end
end