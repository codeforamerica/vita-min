class SendOutgoingTextMessageJob < ApplicationJob
  include Rails.application.routes.url_helpers
  queue_as :default

  def perform(outgoing_text_message_id)
    outgoing_text_message = OutgoingTextMessage.find(outgoing_text_message_id)
    client = Twilio::REST::Client.new(
      EnvironmentCredentials.dig(:twilio, :account_sid),
      EnvironmentCredentials.dig(:twilio, :auth_token)
    )
    message = client.messages.create(
      from: EnvironmentCredentials.dig(:twilio, :phone_number),
      to: outgoing_text_message.case_file.sms_phone_number,
      body: outgoing_text_message.body,
      status_callback: outgoing_text_message_url(outgoing_text_message, locale: nil)
    )
    outgoing_text_message.update(
      twilio_status: message.status,
      twilio_sid: message.sid,
    )
  end
end
