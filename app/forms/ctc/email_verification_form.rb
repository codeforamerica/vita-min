module Ctc
  class EmailVerificationForm < QuestionsForm
    set_attributes_for :misc, :verification_code

    validates_presence_of :verification_code

    def valid?
      return true if Rails.configuration.allow_magic_verification_code && verification_code == "000000"

      hashed_verification_code = VerificationCodeService.hash_verification_code_with_contact_info(@intake.email_address, verification_code)

      puts "test env #{ENV.fetch('TEST_ENV_NUMBER')}: Looking for EmailAccessToken with #{@intake.email_address} & #{verification_code}"
      puts "test env #{ENV.fetch('TEST_ENV_NUMBER')}: hashed verification code is #{hashed_verification_code}"
      puts "test env #{ENV.fetch('TEST_ENV_NUMBER')}: token is #{Devise.token_generator.digest(EmailAccessToken, :token, hashed_verification_code)}"
      puts "test env #{ENV.fetch('TEST_ENV_NUMBER')}: existing tokens are: #{EmailAccessToken.all.pluck(:token)}"

      valid_code = EmailAccessToken.lookup(hashed_verification_code).exists?

      puts "test env #{ENV.fetch('TEST_ENV_NUMBER')}: no token found!" unless valid_code

      errors.add(:verification_code, I18n.t("views.ctc.questions.verification.error_message")) unless valid_code

      valid_code.present?
    end

    def save
      @intake.touch(:email_address_verified_at)
    end
  end
end
