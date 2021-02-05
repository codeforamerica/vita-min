class TwilioWebhooksController < ActionController::Base
  skip_before_action :verify_authenticity_token
  before_action :validate_twilio_request

  def update_outgoing_text_message
    OutgoingTextMessage.find(params[:id]).update(twilio_status: params["MessageStatus"])
    head :ok
  end

  def update_outbound_call
    call = OutboundCall.find(params[:id])
    return unless call.present?

    update_params = { twilio_status: params["CallStatus"] }
    update_params[:twilio_call_duration] = params["CallDuration"] if params["CallDuration"].present?
    call.update(update_params)
  end

  def create_incoming_text_message
    IncomingTextMessageService.process(params)
    head :ok
  end

  def outbound_call_connect
    @outbound_call = OutboundCall.find(params[:id])
    twiml = Twilio::TwiML::VoiceResponse.new
    # The status callback for the call is attached to the dial event to the client.
    # This means that the length of the call will be based on how long the user was connected to the client,
    # And the status will be based on whether the client picked up the call.
    twiml.dial do |dial|
      dial.number(@outbound_call.to_phone_number,
                  status_callback_event: 'answered completed',
                  status_callback: outbound_calls_webhook_url(id: @outbound_call.id, locale: nil),
                  status_callback_method: 'POST')
    end
    render xml: twiml.to_xml
  end

  private

  def validate_twilio_request
    return head 403 unless TwilioService.valid_request?(request)
  end
end
