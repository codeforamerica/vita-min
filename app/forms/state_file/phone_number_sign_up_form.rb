module StateFile
  class PhoneNumberSignUpForm < QuestionsForm
    set_attributes_for :intake, :phone_number

    before_validation :normalize_phone_number
    attr_accessor :verification_code
    validates :phone_number, e164_phone: true

    def save
      @intake.update(attributes_for(:intake))
    end

    def contact_info
      phone_number
    end

    def normalize_phone_number
      self.phone_number = PhoneParser.normalize(phone_number) if phone_number.present?
    end

    def verification_code_valid?
      return true if Rails.configuration.allow_magic_verification_code && verification_code == "000000"

      hashed_verification_code = VerificationCodeService.hash_verification_code_with_contact_info(phone_number, verification_code)

      valid_code = TextMessageAccessToken.lookup(hashed_verification_code).exists?

      errors.add(:verification_code, I18n.t("views.ctc.questions.verification.error_message")) unless valid_code

      valid_code.present?
    end

    def self.attribute_names
      [:phone_number, :verification_code]
    end
  end
end