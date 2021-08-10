module Ctc
  class PhoneVerificationForm < QuestionsForm
    set_attributes_for :intake, :verification_code

    validates_presence_of :verification_code

    def valid?
      return true if verification_code == "000000" && (Rails.env.demo? || Rails.env.development?)

      hashed_verification_code = VerificationCodeService.hash_verification_code_with_contact_info(@intake.sms_phone_number, verification_code)

      valid_code = TextMessageAccessToken.lookup(hashed_verification_code).exists?

      errors.add(:verification_code, I18n.t("views.ctc.questions.verification.error_message")) unless valid_code

      valid_code.present?
    end

    def save
      @intake.touch(:sms_phone_number_verified_at)
    end
  end
end