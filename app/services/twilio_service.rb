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
  end
end
