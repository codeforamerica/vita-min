  class EmailVerificationForm < QuestionsForm
    set_attributes_for :misc, :verification_code

    validates_presence_of :verification_code

    def valid?
      hashed_verification_code = VerificationCodeService.hash_verification_code_with_contact_info(@intake.email_address, verification_code)
      # Magic codes provide a way of bypassing security in a development context.
      # The easiest way to do this was to update the last entry to actually have the magic code.
      if Rails.configuration.allow_magic_verification_code && verification_code == "000000"
        EmailAccessToken.where(email_address: @intake.email_address).last.update(
          token: Devise.token_generator.digest(EmailAccessToken, :token, hashed_verification_code),
        )
        return true
      end

      valid_code = EmailAccessToken.lookup(hashed_verification_code).exists?

      errors.add(:verification_code, I18n.t("views.questions.verification.error_message")) unless valid_code

      valid_code.present?
    end

    def save
      @intake.touch(:email_address_verified_at)
    end
  end
