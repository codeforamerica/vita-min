class SendOutgoingTextMessageJob < ApplicationJob
  include Rails.application.routes.url_helpers
  queue_as :default

  def perform(outgoing_text_message_id)
    outgoing_text_message = OutgoingTextMessage.find(outgoing_text_message_id)

    message = begin
                TwilioService.send_text_message(
                  to: outgoing_text_message.to_phone_number,
                  body: outgoing_text_message.body,
                  status_callback: outgoing_text_message_url(outgoing_text_message, locale: nil)
                )
              rescue Twilio::REST::RestError
                outgoing_text_message.update(twilio_status: "twilio_error")
                raise
              end

    outgoing_text_message.update(
      twilio_status: message.status,
      twilio_sid: message.sid,
      sent_at: DateTime.now
    )
  end
end
