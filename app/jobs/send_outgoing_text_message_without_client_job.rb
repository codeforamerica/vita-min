class SendOutgoingTextMessageWithoutClientJob < ApplicationJob
  def perform(phone_number: , body: )
    TwilioService.send_text_message(
      to: phone_number,
      body: body,
    )

    DatadogApi.increment("twilio.outgoing_text_messages.sent")
  end

  def priority
    low_priority
  end
end
