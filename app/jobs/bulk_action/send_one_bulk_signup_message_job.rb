module BulkAction
  class SendOneBulkSignupMessageJob < ApplicationJob
    include Rails.application.routes.url_helpers

    def perform(signup, bulk_signup_message)
      outgoing_message_status = BulkSignupMessageOutgoingMessageStatus.create!(
        bulk_signup_message: bulk_signup_message,
        outgoing_message_status: OutgoingMessageStatus.new(parent: signup, message_type: bulk_signup_message.message_type, delivery_status: "pending")
      ).outgoing_message_status

      message_id =
        case bulk_signup_message.message_type
        when "sms"
          TwilioService.send_text_message(
            to: signup.phone_number,
            body: bulk_signup_message.message,
            status_callback: twilio_update_status_path(outgoing_message_status.id, locale: nil),
            outgoing_text_message: outgoing_message_status
          )&.sid
        when "email"
          service_info = MultiTenantService.new(signup.class.name == "CtcSignup" ? :ctc : :gyr)
          SignupFollowupMailer.new.followup(email_address: signup.email_address, message: OpenStruct.new(
            email_body: bulk_signup_message.message,
            service_type: service_info.service_type,
            email_subject: I18n.t("messages.default_subject_with_service_name", service_name: service_info.service_name, locale: "en")
          )).deliver.message_id
        end
      outgoing_message_status.update(message_id: message_id) if message_id.present?
    end
  end
end
