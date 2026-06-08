class DeduplicationService
  def self.sensitive_attribute_hashed(instance, attr, key = ENV["DUPLICATE_HASHING_KEY"]
    value = instance.send(attr)
    return unless value.present?
    # we want to hash all ssns the same way so that data can dedupe across the board
    attr = :primary_ssn if attr == :spouse_ssn || attr == :ssn
    OpenSSL::HMAC.hexdigest("SHA256", key, "#{attr}|#{value}")
  end

  def self.duplicates(instance, *attrs, from_scope:)
    match_on = Array(attrs).inject({}) do |hash, attr|
      hash[attr] = values(instance, attr)
      hash
    end

    from_scope.where.not(id: instance.id).where(match_on)
  end

  def self.values(instance, attr)
    _, attr_without_hashed = attr.to_s.split("hashed_")
    return instance.send(attr) if attr_without_hashed.nil?

    old_key = ENV["PREVIOUS_DUPLICATE_HASHING_KEY"]
    return instance.send(attr) unless old_key.present?

    [sensitive_attribute_hashed(instance, attr_without_hashed), sensitive_attribute_hashed(instance, attr_without_hashed, old_key)]
  end
end
