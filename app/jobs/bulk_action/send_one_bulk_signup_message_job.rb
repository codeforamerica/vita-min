module BulkAction
  class SendOneBulkSignupMessageJob < ApplicationJob
    include Rails.application.routes.url_helpers

    def perform(signup, bulk_signup_message)
      if bulk_signup_message.message_type == 'sms'
        outgoing_message_status = OutgoingMessageStatus.create(message_type: bulk_signup_message.message_type, delivery_status: "pending")
        message = TwilioService.send_text_message(
          to: signup.phone_number,
          body: bulk_signup_message.message,
          status_callback: twilio_update_status_path(outgoing_message_status.id, locale: nil),
        )
        outgoing_message_status.update(message_id: message.sid)
      end
    end
  end
end
