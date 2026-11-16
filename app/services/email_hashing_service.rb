class EmailHashingService
  def self.hash(email)
    return unless email.present?

    normalized = email.strip.downcase
    OpenSSL::HMAC.hexdigest(
      "SHA256",
      EnvironmentCredentials['DUPLICATE_HASHING_KEY'],
      "email|#{normalized}"
    )
  end
end
