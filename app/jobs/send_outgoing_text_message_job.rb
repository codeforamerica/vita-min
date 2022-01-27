class SendOutgoingTextMessageJob < ApplicationJob
  include Rails.application.routes.url_helpers
  queue_as :default

  def perform(outgoing_text_message_id)
    outgoing_text_message = OutgoingTextMessage.find(outgoing_text_message_id)

    message = TwilioService.send_text_message(
      to: outgoing_text_message.to_phone_number,
      body: outgoing_text_message.body,
      status_callback: outgoing_text_message_url(outgoing_text_message, locale: nil),
      outgoing_text_message: outgoing_text_message
    )

    outgoing_text_message.update(
      twilio_status: message.status,
      twilio_sid: message.sid,
      sent_at: DateTime.now
    )
  end

  def priority
    low_priority
  end
end
