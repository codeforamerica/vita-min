class TwilioService
  FAILED_STATUSES = %w(undelivered failed delivery_unknown twilio_error)
  SUCCESSFUL_STATUSES = %w(sent delivered)
  IN_PROGRESS_STATUSES = %w(accepted queued sending) << nil
  ALL_KNOWN_STATUSES = FAILED_STATUSES + SUCCESSFUL_STATUSES + IN_PROGRESS_STATUSES
  ORDERED_STATUSES = %w(
    twilio_error
    queued
    accepted
    sending
    sent
    delivery_unknown
    delivered
    undelivered
    failed
  ).unshift(nil) # why do we need nil in this list, and why must it be first?

  attr_reader :client, :messaging_service_sid, :auth_token

  def initialize(service_type = :gyr)
    creds = MultiTenantService.new(service_type).twilio_creds
    @messaging_service_sid = creds[:messaging_service_sid]
    @auth_token = creds[:auth_token]
    @client = Twilio::REST::Client.new(creds[:account_sid], auth_token)
  end

  def send_text_message(to:, body:, status_callback: nil, outgoing_text_message: nil)
    arguments = {
      messaging_service_sid: ENV['MESSAGING_SERVICE_SID'] || messaging_service_sid, # why do we check the environment for this??
      to: to,
      body: body
    }
    arguments[:status_callback] = status_callback if status_callback.present?

    DatadogApi.increment("twilio.outgoing_text_messages.sent")

    client.messages.create(**arguments)
  rescue Twilio::REST::RestError => e
    status_key =
      if outgoing_text_message.is_a?(OutgoingMessageStatus)
        :delivery_status
      else
        :twilio_status
      end
    outgoing_text_message&.update(status_key => "twilio_error")

    unless e.code == 21211 # Invalid 'To' Phone Number https://www.twilio.com/docs/api/errors/21211
      raise # should we include the original exception here (e)??
    end

    nil
  end

  def get_metadata(phone_number:)
    client.lookups.v2.phone_numbers(phone_number).fetch(fields: 'line_type_intelligence').line_type_intelligence
  rescue Twilio::REST::RestError
    {}
  end

  def valid_request?(request)
    validator = Twilio::Security::RequestValidator.new(auth_token)
    validator.validate(
      request.url,
      request.POST,
      request.headers["X-Twilio-Signature"],
    )
  end

  def fetch_attachment(url)
    response = Net::HTTP.get_response(URI(url)) # first we get a redirect from Twilio to S3
    response = Net::HTTP.get_response(URI(response['location'])) # then we get a redirect from S3 to S3
    response = Net::HTTP.get_response(URI(response['location'])) # finally we should get a 200 OK with the file
    filename_from_s3 = response['content-disposition'].split('"').last # S3 gives us the original filename
    {
      filename: filename_from_s3,
      body: response.body,
    }
  rescue ArgumentError => e
    Rails.logger.error("Error getting attachment from Twilio: #{url}: #{response&.code}: #{response&.to_hash}")
    {
      filename: "unknown-file",
      body: nil
    }
  end

  def parse_attachments(params)
    num_media = params["NumMedia"].to_i

    (0...num_media).map do |i|
      content_type = params["MediaContentType#{i}"]
      attachment = fetch_attachment(params["MediaUrl#{i}"])

      if FileTypeAllowedValidator.mime_types(Document).include?(content_type) && !attachment[:body].empty?
        {
          content_type: params["MediaContentType#{i}"],
          filename: attachment[:filename],
          body: attachment[:body]
        }
      else
        {
          content_type: "text/plain;charset=UTF-8",
          filename: "invalid-#{attachment[:filename]}.txt",
          body: <<~TEXT
            Unusable file with unknown or unsupported file type.
            File name: #{attachment[:filename]}
            File type: #{content_type}
            File size: #{attachment[:body].size} bytes
          TEXT
        }
      end
    end
  end
end
