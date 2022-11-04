module BulkAction
  class SendOneBulkSignupMessageJob < ApplicationJob
    include Rails.application.routes.url_helpers

    def perform(signup, bulk_signup_message)
      if bulk_signup_message.message_type == 'sms'
        message = TwilioService.send_text_message(
          to: signup.phone_number,
          body: bulk_signup_message.message,
          status_callback: nil, #TODO what is the callback?
        )

        if message
          # TODO the outgoing message status needs to be tied back to the bulk signup message i think
          OutgoingMessageStatus.create(message_id: message.sid, message_type: bulk_signup_message.message_type, delivery_status: message.status)
        end
      end
    end
  end
end
