class MailgunService
  class << self
    def valid_post?(params)
      signing_key = EnvironmentCredentials.dig(:mailgun, :webhook_signing_key)
      token = params["token"]
      timestamp = params["timestamp"]
      signature = params["signature"]

      digest = OpenSSL::Digest::SHA256.new
      data = [timestamp, token].join
      expected_hmac = OpenSSL::HMAC.hexdigest(digest, signing_key, data)
      ActiveSupport::SecurityUtils.fixed_length_secure_compare(signature, expected_hmac)
    end
  end
end
