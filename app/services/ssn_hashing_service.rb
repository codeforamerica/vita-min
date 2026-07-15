class SsnHashingService
  def self.hash(ssn)
    OpenSSL::HMAC.hexdigest(
      "SHA256",
      EnvironmentCredentials['DUPLICATE_HASHING_KEY'],
      "ssn|#{ssn}"
    )
  end
end