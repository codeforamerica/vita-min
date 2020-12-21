class TwilioWebhooksController < ActionController::Base
  skip_before_action :verify_authenticity_token
  before_action :validate_twilio_request

  def update_outgoing_text_message
    OutgoingTextMessage.find(params[:id]).update(twilio_status: params["MessageStatus"])
    head :ok
  end

  def update_outbound_call
    call = OutboundCall.find_by(twilio_sid: params["CallSid"])
    return unless call.present?

    update_params = { twilio_status: params["CallStatus"] }
    update_params[:call_duration] = params["CallDuration"] if params["CallDuration"].present?
    call.update(update_params)
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
end
