# frozen_string_literal: true

class SendOutgoingTextMessageToNonConsentingClientJob < ApplicationJob
  queue_as :default

  def perform(phone_number: )
    TwilioService.send_text_message(
      to: phone_number,
      body: AutomatedMessage::UnmonitoredReplies.new.sms_body(support_email: Rails.configuration.email_from[:support][:gyr]),
      )

    DatadogApi.increment("twilio.outgoing_text_messages_to_non_consenting_client.sent")
  end

  def priority
    low_priority
  end
end
