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
    update_params[:call_duration] = params["CallDuration"] if params["CallDuration"].present?
    call.update(update_params)
  end

  # This url is used to provide instructions to Twilio for how to handle calls from the user to the client from the
  # OutboundCallForm. Once the user picks up and connects, we dial the clients phone number.
  def dial_client
    @outbound_call = OutboundCall.find(params[:id])
    twiml = Twilio::TwiML::VoiceResponse.new
    twiml.say(message: 'Please wait while we connect your call.')
    # The status callback for the call is attached to the dial event to the client.
    # This means that the length of the call will be based on how long the user was connected to the client,
    # And the status will be based on whether the client picked up the call.
    twiml.dial do |dial|
      dial.number(@outbound_call.to_phone_number,
                  status_callback_event: 'answered completed',
                  status_callback: _outbound_call_webhook_url(@outbound_call),
                  status_callback_method: 'POST')
    end
    render xml: twiml.to_xml
  end

  def create_incoming_text_message
    phone_number = PhoneParser.normalize(params["From"])
    intake_by_phone_number = Intake.where(phone_number: phone_number).where.not(client: nil)
    intake_by_sms_phone_number = Intake.where(sms_phone_number: phone_number).where.not(client: nil)
    if intake_by_phone_number.count > 0
      client = intake_by_phone_number.first.client
    else
      client = intake_by_sms_phone_number.first&.client
    end
    unless client.present?
      client = Client.create!(intake: Intake.create!(phone_number: phone_number, sms_phone_number: phone_number))
    end

    contact_record = IncomingTextMessage.create!(
      body: params["Body"],
      received_at: DateTime.now,
      from_phone_number: phone_number,
      client: client,
    )

    attachments = TwilioService.new(params).parse_attachments
    attachments.each do |attachment|
      client.documents.create!(
        document_type: DocumentTypes::TextMessageAttachment.key,
        contact_record: contact_record,
        upload: {
          io: StringIO.new(attachment[:body]),
          filename: attachment[:filename],
          content_type: attachment[:content_type],
          identify: false
        }
      )
    end

    ClientChannel.broadcast_contact_record(contact_record)
    head :ok
  end

  private

  def validate_twilio_request
    return head 403 unless TwilioService.valid_request?(request)
  end

  def _outbound_call_webhook_url(outbound_call)
    params = { id: outbound_call.id, locale: nil }

    if Rails.env.development?
      raise NgrokNeededError unless Rails.configuration.try(:ngrok_url).present?

      return Rails.configuration.ngrok_url + outbound_calls_webhook_path(params)
    end
    outbound_calls_webhook_url(params)
  end
end
