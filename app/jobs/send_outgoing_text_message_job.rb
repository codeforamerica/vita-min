class SendOutgoingTextMessageJob < ApplicationJob
  include Rails.application.routes.url_helpers
  queue_as :default

  def perform(outgoing_text_message_id)
    outgoing_text_message = OutgoingTextMessage.find(outgoing_text_message_id)

    # process any unprocessed sensitive parameter placeholders
    sensitive_body = ReplacementParametersService.new(
      body: outgoing_text_message.body,
      client: outgoing_text_message.client,
      locale: outgoing_text_message.client.intake.locale
    ).process_sensitive_data

    message = TwilioService.send_text_message(
      to: outgoing_text_message.to_phone_number,
      body: sensitive_body,
      status_callback: outgoing_text_message_url(outgoing_text_message, locale: nil)
    )

    outgoing_text_message.update(
      twilio_status: message.status,
      twilio_sid: message.sid,
    )
  end
end
