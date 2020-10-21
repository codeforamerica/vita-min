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

    contact_record = IncomingTextMessage.create!(
      body: params["Body"],
      received_at: DateTime.now,
      from_phone_number: phone_number,
      client: client,
    )
    num_media = params['NumMedia'].to_i

    (0..(num_media - 1)).each do |i|
      media_url = params["MediaUrl#{i}"]
      content_type = params["MediaContentType#{i}"]
      extension = MIME::Types[content_type].first.extensions.first
      filename_with_extension = "#{media_url.split('/').last}.#{extension}"
      contact_record.documents.attach(io: StringIO.new(Net::HTTP.get(URI(media_url))),
                                        filename: filename_with_extension,
                                        content_type: content_type,
                                        identify: false)
    end

    ClientChannel.broadcast_contact_record(contact_record)
    head :ok
  end

  private

  def validate_twilio_request
    return head 403 unless TwilioService.valid_request?(request)
  end
end