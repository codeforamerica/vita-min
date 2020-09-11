class MailgunService
  class << self
    def valid_post?(params)
      # Mailgun documentation on securing webhooks
      #   https://documentation.mailgun.com/en/latest/user_manual.html#webhooks
      signing_key = EnvironmentCredentials.dig(:mailgun, :webhook_signing_key)
      token = params["token"]
      timestamp = params["timestamp"]
      signature = params["signature"]

      digest = OpenSSL::Digest::SHA256.new
      data = [timestamp, token].join
      expected_hmac = OpenSSL::HMAC.hexdigest(digest, signing_key, data)
      # Use constant-time comparison to prevent timing-based key discovery attacks:
      ActiveSupport::SecurityUtils.fixed_length_secure_compare(signature, expected_hmac)
    end
  end
end
