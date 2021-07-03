module Ctc
  module Questions
    class CellPhoneNumberController < QuestionsController
      include AnonymousIntakeConcern

      layout "intake"

      def self.show?(intake)
        ClientMessagingService.contact_methods(intake.client).empty?
      end

      def update
        super
      end

      private

      def prev_path
        questions_contact_preference_path
      end

      def illustration_path
        "phone-number.svg"
      end
    end
  end
end