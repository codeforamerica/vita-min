class DeduplificationService
  def self.hmac_hexdigest(value)
    key = EnvironmentCredentials.dig(:hash_key)
    OpenSSL::HMAC.hexdigest("SHA256", key, value)
  end

  def self.detect_duplicates(instance, *attrs)
    match_on = Array(attrs).inject({}) do |hash, attr|
      hash[attr] = instance.send(attr)
      hash
    end
    instance.class.where.not(id: instance.id).where(match_on).exists?
  end
end