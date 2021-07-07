module Ctc
  module Questions
    class EmailAddressController < QuestionsController
      include AnonymousIntakeConcern

      layout "intake"

      private

      def next_path
        questions_consent_path #TODO: should redirect to verify-identity
      end

      def prev_path
        questions_contact_preference_path
      end
    end
  end
end