class SsnHashingService
  def self.hash(ssn)
    OpenSSL::HMAC.hexdigest(
      "SHA256",
      EnvironmentCredentials.dig(:duplicate_hashing_key),
      "ssn|#{ssn}"
    )
  end
end