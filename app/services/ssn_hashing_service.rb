class SsnHashingService
  def self.hash(ssn)
    OpenSSL::HMAC.hexdigest(
      "SHA256",
      ENV["DUPLICATE_HASHING_KEY"] || EnvironmentCredentials.dig(:duplicate_hashing_key),
      "ssn|#{ssn}"
    )
  end
end