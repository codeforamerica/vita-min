class SendOutgoingTextMessageJob < ApplicationJob
  include Rails.application.routes.url_helpers

  def perform(outgoing_text_message_id)
    outgoing_text_message = OutgoingTextMessage.find(outgoing_text_message_id)
    begin
      message = TwilioService.new(:gyr).send_text_message(
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
    rescue Net::OpenTimeout
      DatadogApi.increment("twilio.outgoing_text_messages.failure.timeout")
      outgoing_text_message.update_status_if_further("twilio_error", error_code: nil)
      retry_job
    end
  end

  def priority
    PRIORITY_HIGH
  end
end
