module StateFile
  class EmailSignUpForm < QuestionsForm
    set_attributes_for :intake, :email_address
    attr_accessor :verification_code

    validates :email_address, 'valid_email_2/email': true
    validates :email_address, presence: true

    def save
      @intake.update(attributes_for(:intake).merge(email_address_verified_at: DateTime.now))
    end

    def contact_info
      email_address
    end

    def verification_code_valid?
      hashed_verification_code = VerificationCodeService.hash_verification_code_with_contact_info(email_address, verification_code)
      # Magic codes provide a way of bypassing security in a development context.
      # The easiest way to do this was to update the last entry to actually have the magic code.
      if Rails.configuration.allow_magic_verification_code && verification_code == "000000"
        token = EmailAccessToken.where(email_address: email_address).last
        if token.present?
          token.update(
            token: Devise.token_generator.digest(EmailAccessToken, :token, hashed_verification_code),
            )
        end
        return true
      end

      valid_code = EmailAccessToken.lookup(hashed_verification_code).exists?

      errors.add(:verification_code, I18n.t("views.questions.verification.error_message")) unless valid_code

      valid_code.present?
    end

    def self.attribute_names
      [:email_address, :verification_code]
    end
  end
end