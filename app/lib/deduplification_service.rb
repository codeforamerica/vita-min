class DeduplificationService
  def self.sensitive_attribute_hashed(instance, attr, key = EnvironmentCredentials.dig(:duplicate_hashing_key))
    value = instance.send(attr)
    return unless value.present?

    OpenSSL::HMAC.hexdigest("SHA256", key, "#{attr}|#{value}")
  end

  def self.duplicates(instance, *attrs)
    match_on = Array(attrs).inject({}) do |hash, attr|
      hash[attr] = values(instance, attr)
      hash
    end
    instance.class.where.not(id: instance.id).where(match_on)
  end

  def self.values(instance, attr)
    _, attr_without_hashed = attr.to_s.split("hashed_")
    return instance.send(attr) if attr_without_hashed.nil?

    old_key = EnvironmentCredentials.dig(:previous_duplicate_hashing_key)
    return instance.send(attr) unless old_key.present?

    [sensitive_attribute_hashed(instance, attr_without_hashed), sensitive_attribute_hashed(instance, attr_without_hashed, old_key)]
  end
end
