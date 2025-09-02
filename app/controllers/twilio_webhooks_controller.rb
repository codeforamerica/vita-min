class TwilioWebhooksController < ActionController::Base
  skip_before_action :verify_authenticity_token
  before_action :validate_twilio_request

  def update_outgoing_text_message
    status = strong_params["MessageStatus"]
    DatadogApi.increment("twilio.outgoing_text_messages.updated.status.#{status}")
    OutgoingTextMessage.find(strong_params[:id]).update_status_if_further(status, error_code: strong_params["ErrorCode"])
    head :ok
  end

  def update_status
    status = strong_params["MessageStatus"]
    DatadogApi.increment("twilio.outgoing_messages.updated.status.#{status}")
    OutgoingMessageStatus.find_by(id: strong_params[:id], message_type: :sms).update_status_if_further(status, error_code: strong_params["ErrorCode"])
    head :ok
  end

  def update_outbound_call
    call = OutboundCall.find(strong_params[:id])
    return unless call.present?

    update_params = { twilio_status: strong_params["CallStatus"] }
    DatadogApi.increment("twilio.outbound_calls.updated.status.#{strong_params["CallStatus"]}")

    if strong_params["CallDuration"].present?
      update_params[:twilio_call_duration] = strong_params["CallDuration"]
      DatadogApi.gauge("twilio.outbound_calls.updated.duration", strong_params["CallDuration"].to_i)
    end

    call.update!(update_params)
  end

  def create_incoming_text_message
    IncomingTextMessageService.process(strong_params.to_h)
    head :ok
  end

  def outbound_call_connect
    @outbound_call = OutboundCall.find(strong_params[:id])
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
    DatadogApi.increment("twilio.outbound_calls.connected")
    render xml: twiml.to_xml
  end

  private

  def validate_twilio_request
    head 403 unless TwilioService.new.valid_request?(request)
  end

  def strong_params
    num_media = params.permit("NumMedia")["NumMedia"]

    # Have to do this a little weird to get around dealing with embedded indices
    media_keys = Array.new(num_media.to_i) do |iter|
      ["MediaUrl#{iter}", "MediaContentType#{iter}"]
    end.flatten

    params.permit(
      "id",
      "ErrorCode",
      "CallDuration",
      "MessageStatus",
      "CallStatus",
      "Body",
      "NumMedia",
      "From",
      *media_keys
    )
  end
end
