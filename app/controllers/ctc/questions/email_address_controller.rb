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
        questions_email_verification_path
      end
    end
  end
end