module Ctc
  module Questions
    class EmailAddressController < QuestionsController
      include AnonymousIntakeConcern

      layout "intake"

      def self.show?(intake)
        ClientMessagingService.contact_methods(intake.client).empty?
      end

      private

      def prev_path
        questions_contact_preference_path
      end
    end
  end
end