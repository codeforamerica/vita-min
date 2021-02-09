class SendOutgoingTextMessageJob < ApplicationJob
  include Rails.application.routes.url_helpers
  queue_as :default

  def perform(outgoing_text_message_id)
    outgoing_text_message = OutgoingTextMessage.find(outgoing_text_message_id)

    twilio_client = Twilio::REST::Client.new(
      EnvironmentCredentials.dig(:twilio, :account_sid),
      EnvironmentCredentials.dig(:twilio, :auth_token)
    )

    # process any unprocessed sensitive parameter placeholders
    sensitive_body = ReplacementParametersService.new(
      body: outgoing_text_message.body,
      client: outgoing_text_message.client,
      locale: outgoing_text_message.client.intake.locale
    ).process_sensitive_data

    message = twilio_client.messages.create(
      messaging_service_sid: EnvironmentCredentials.dig(:twilio, :messaging_service_sid),
      to: outgoing_text_message.to_phone_number,
      body: sensitive_body,
      status_callback: outgoing_text_message_url(outgoing_text_message, locale: nil)
    )

    DatadogApi.increment("twilio.outgoing_text_messages.sent")

    outgoing_text_message.update(
      twilio_status: message.status,
      twilio_sid: message.sid,
    )
  end
end
