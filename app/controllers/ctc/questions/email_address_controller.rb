module Ctc
  module Questions
    class EmailAddressController < QuestionsController
      include AnonymousIntakeConcern

      layout "intake"

      # # for simplifications sake, since we only require one contact method, skip if they've provided phone number
      # def self.show?(intake)
      #   intake.sms_phone_number.blank?
      # end

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