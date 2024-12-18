class PhoneVerificationForm < QuestionsForm
  set_attributes_for :misc, :verification_code

  validates_presence_of :verification_code

  def valid?
    hashed_verification_code = VerificationCodeService.hash_verification_code_with_contact_info(@intake.sms_phone_number, verification_code)
    # Magic codes provide a way of bypassing security in a development context.
    # The easiest way to do this was to update the last entry to actually have the magic code.
    if Rails.configuration.allow_magic_verification_code && verification_code == "000000"
      token = TextMessageAccessToken.where(sms_phone_number: @intake.phone_number).last
      if token.present?
        token.update(
          token: Devise.token_generator.digest(TextMessageAccessToken, :token, hashed_verification_code),
          )
      end
      return true
    end

    valid_code = TextMessageAccessToken.lookup(hashed_verification_code).exists?

    errors.add(:verification_code, I18n.t("views.questions.verification.error_message")) unless valid_code

    valid_code.present?
  end

  def save
    @intake.touch(:sms_phone_number_verified_at)
  end
end
