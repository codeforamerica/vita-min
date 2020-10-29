class TwilioWebhooksController < ActionController::Base
  skip_before_action :verify_authenticity_token
  before_action :validate_twilio_request

  def update_outgoing_text_message
    OutgoingTextMessage.find(params[:id]).update(twilio_status: params["MessageStatus"])
    head :ok
  end

  def create_incoming_text_message
    phone_number = Phonelib.parse(params["From"]).sanitized
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
    num_media = params['NumMedia'].to_i

    (0..(num_media - 1)).each do |i|
      content_type = params["MediaContentType#{i}"]
      media_url = params["MediaUrl#{i}"]
      document = client.documents.create!(
        document_type: DocumentTypes::TextMessageAttachment.key,
        contact_record: contact_record
      )
      response = Net::HTTP.get_response(URI(media_url)) # first we get a redirect from Twilio to S3
      response = Net::HTTP.get_response(URI(response['location'])) # then we get a redirect from S3 to S3
      response = Net::HTTP.get_response(URI(response['location'])) # finally we should get a 200 OK with the file
      filename_from_s3 = response['content-disposition'].split('"').last # S3 gives us the original filename

      if FileTypeAllowedValidator::VALID_MIME_TYPES.include? content_type
        document.upload.attach(
          io: StringIO.new(response.body),
          filename: filename_from_s3,
          content_type: content_type,
          identify: false
        )
        document.update(display_name: filename_from_s3)
      else
        io = StringIO.new <<~TEXT
          Unusable file with unknown or unsupported file type.
          File name:'#{filename_from_s3}'
          File type:'#{content_type}'
        TEXT
        document.upload.attach(
          io: io,
          filename: "invalid-#{filename_from_s3}.txt",
          content_type: "text/plain;charset=UTF-8",
          identify: false
        )
      end
    end

    ClientChannel.broadcast_contact_record(contact_record)
    head :ok
  end

  private

  def validate_twilio_request
    return head 403 unless TwilioService.valid_request?(request)
  end
end