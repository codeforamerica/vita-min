class HashAttribute
  def self.hmac_hexdigest(attribute)
    key = Rails.configuration.secret_key_base
    OpenSSL::HMAC.hexdigest("SHA256", key, attribute)
  end
end