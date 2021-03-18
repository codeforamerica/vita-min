class VerificationCodeService
  def self.generate(contact_info)
    verification_code = "%06d" % SecureRandom.rand(1000000)
    [verification_code, hash_verification_code_with_contact_info(contact_info, verification_code)]
  end

  def self.hash_verification_code_with_contact_info(contact_info, verification_code)
    Devise.token_generator.digest(VerificationCodeService, :verification_code, "#{contact_info},#{verification_code}")
  end
end
