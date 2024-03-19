module BulkAction
  class SendOneBulkSignupMessageJob < ApplicationJob
    include Rails.application.routes.url_helpers

    def perform(signup, bulk_signup_message)
      if bulk_signup_message.message_type == "sms"
        line_type = TwilioService.get_metadata(phone_number: signup.phone_number)&.dig("type")
        if line_type == "landline"
          DatadogApi.increment("twilio.outgoing_text_messages.bulk_signup_message_not_sent_landline")
          return
        end
      end

      outgoing_message_status = BulkSignupMessageOutgoingMessageStatus.create!(
        bulk_signup_message: bulk_signup_message,
        outgoing_message_status: OutgoingMessageStatus.new(parent: signup, message_type: bulk_signup_message.message_type)
      ).outgoing_message_status

      message_id =
        case bulk_signup_message.message_type
        when "sms"
          TwilioService.send_text_message(
            to: signup.phone_number,
            body: bulk_signup_message.message,
            status_callback: twilio_update_status_url(outgoing_message_status.id, locale: nil),
            outgoing_text_message: outgoing_message_status
          )&.sid
        when "email"
          service_info = MultiTenantService.new(signup.class.name == "CtcSignup" ? :ctc : :gyr)
          SignupFollowupMailer.new.followup(email_address: signup.email_address, message: OpenStruct.new(
            email_body: bulk_signup_message.message,
            service_type: service_info.service_type,
            email_subject: bulk_signup_message.subject
          )).deliver.message_id
        end
      outgoing_message_status.update(message_id: message_id) if message_id.present?
    end

    def priority
      PRIORITY_LOW
    end
  end
end
