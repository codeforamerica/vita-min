class SendOutgoingTextMessageJob < ApplicationJob
  include Rails.application.routes.url_helpers
  queue_as :default

  def perform(outgoing_text_message_id)
    outgoing_text_message = OutgoingTextMessage.find(outgoing_text_message_id)
    client = Twilio::REST::Client.new(
      EnvironmentCredentials.dig(:twilio, :account_sid),
      EnvironmentCredentials.dig(:twilio, :auth_token)
    )
    params = {
      from: EnvironmentCredentials.dig(:twilio, :phone_number),
      to: outgoing_text_message.case_file.sms_phone_number,
      body: outgoing_text_message.body,
    }
    unless Rails.env.development?
      verifiable_outgoing_text_message_id = ActiveSupport::MessageVerifier.new(EnvironmentCredentials.dig(:secret_key_base)).generate(
        outgoing_text_message.id.to_s, purpose: :twilio_text_message_status_callback
      )
      params[:status_callback] = case_files_text_status_callback_url(
        verifiable_outgoing_text_message_id: verifiable_outgoing_text_message_id
      )
    end
    message = client.messages.create(params)
    outgoing_text_message.update(
      twilio_status: message.status,
      twilio_sid: message.sid,
    )
  end
end
