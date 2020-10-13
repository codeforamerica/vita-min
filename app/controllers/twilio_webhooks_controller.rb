class TwilioWebhooksController < ActionController::Base
  skip_before_action :verify_authenticity_token
  before_action :validate_twilio_request

  def update_outgoing_text_message
    OutgoingTextMessage.find(params[:id]).update(twilio_status: params["MessageStatus"])
    head :ok
  end

  def create_incoming_text_message
    phone_number = Phonelib.parse(params["From"]).sanitized
    client = Client.where(phone_number: phone_number).or(Client.where(sms_phone_number: phone_number)).first
    unless client.present?
      client = Client.create!(phone_number: phone_number, sms_phone_number: phone_number)
    end

    IncomingTextMessage.create!(
      body: params["Body"],
      received_at: DateTime.now,
      from_phone_number: phone_number,
      client: client,
    )
    ClientChannel.broadcast_to(client, [".message-list", '<p id="#new-message">A new message has arrived. Please reload.</p>'])
    head :ok
  end

  private

  def validate_twilio_request
    return head 403 unless TwilioService.valid_request?(request)
  end
end