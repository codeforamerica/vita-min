class SendOutgoingTextMessageWithoutClientJob < ApplicationJob
  def perform(phone_number:, body:)
    TwilioService.new(:gyr).send_text_message(
      to: phone_number,
      body: body,
    )

    DatadogApi.increment("twilio.outgoing_text_messages.sent")
  rescue Twilio::REST::TwilioError => e
    if e.cause == Net::OpenTimeout
      DatadogApi.increment("twilio.outgoing_text_messages.failure.timeout")
      retry_job(outgoing_text_message_id)
    end
  end

  def priority
    PRIORITY_HIGH
  end
end
