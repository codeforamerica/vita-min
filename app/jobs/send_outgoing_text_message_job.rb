class SendOutgoingTextMessageJob < ApplicationJob
  include Rails.application.routes.url_helpers

  def perform(outgoing_text_message_id)
    outgoing_text_message = OutgoingTextMessage.find(outgoing_text_message_id)
    message = TwilioService.send_text_message(
      to: outgoing_text_message.to_phone_number,
      body: outgoing_text_message.body,
      status_callback: outgoing_text_message_url(outgoing_text_message, locale: nil),
      outgoing_text_message: outgoing_text_message
    )

    if message
      outgoing_text_message.update(
        twilio_sid: message.sid,
        sent_at: DateTime.now
      )
      outgoing_text_message.update_status_if_further(message.status, error_code: message.error_code)
    end
  end

  def priority
    PRIORITY_HIGH
  end
end
