module Ctc
  module Questions
    class EmailAddressController < QuestionsController
      include AnonymousIntakeConcern

      layout "intake"

      private

      def after_update_success
        ClientEmailVerificationRequestJob.perform_later(
          email_address: @form.email_address,
          locale: I18n.locale,
          visitor_id: current_intake.visitor_id
        )
      end

      def prev_path
        questions_contact_preference_path
      end

      def next_path
        questions_placeholder_question_path # replace with verify identity path
      end
    end
  end
end