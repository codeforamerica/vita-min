class TwilioService
  class << self
    def valid_request?(request)
      validator = Twilio::Security::RequestValidator.new(EnvironmentCredentials.dig(:twilio, :auth_token))
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
    end

    def parse_attachments(params)
      num_media = params["NumMedia"].to_i

      (0..(num_media - 1)).map do |i|
        content_type = params["MediaContentType#{i}"]
        attachment = fetch_attachment(params["MediaUrl#{i}"])

        if FileTypeAllowedValidator::VALID_MIME_TYPES.include?(content_type) && !attachment[:body].empty?
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

    def client
      @@_client ||= Twilio::REST::Client.new(
        EnvironmentCredentials.dig(:twilio, :account_sid),
        EnvironmentCredentials.dig(:twilio, :auth_token)
      )
    end

    def send_text_message(to:, body:, status_callback: nil, outgoing_text_message: nil)
      arguments = {
        messaging_service_sid: EnvironmentCredentials.dig(:twilio, :messaging_service_sid),
        to: to,
        body: body
      }
      arguments[:status_callback] = status_callback if status_callback.present?

      DatadogApi.increment("twilio.outgoing_text_messages.sent")

      client.messages.create(arguments)
    rescue Twilio::REST::RestError => e
      outgoing_text_message.update(twilio_status: "twilio_error") if outgoing_text_message
      unless e.code == 21211 # Invalid 'To' Phone Number https://www.twilio.com/docs/api/errors/21211
        raise
      end
    end
  end
end
