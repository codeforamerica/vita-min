module StateFile
  module Questions
    class PhoneNumberSignUpController < EmailSignUpController

      def self.show?(intake)
        intake.contact_preference == "text"
      end

      private

      def send_verification_code
        RequestVerificationCodeTextMessageJob.perform_later(
          phone_number: @form.phone_number,
          locale: I18n.locale,
          visitor_id: current_intake.visitor_id,
          client_id: nil,
          service_type: :statefile
        )
      end

      def get_existing_intake(intake, contact_info)
        search = intake.class.where.not(id: intake.id)
        search = search.where(phone_number: contact_info)
        search.first
      end

      def after_update_success
        messaging_service = StateFile::MessagingService.new(
          message: StateFile::AutomatedMessage::Welcome,
          intake: current_intake,
          sms: true,
          email: false,
          body_args: {intake_id: current_intake.id}
        )
        messaging_service.send_message
      end

    end
  end
end