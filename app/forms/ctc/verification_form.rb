module Ctc
  class VerificationForm < QuestionsForm
    set_attributes_for :intake, :verification_code

    validates_presence_of :verification_code

    def valid?
      contact_info = @intake.send(contact_method)
      hashed_verification_code = VerificationCodeService.hash_verification_code_with_contact_info(contact_info, verification_code)

      valid_code = if contact_method == :sms_phone_number
                     TextMessageAccessToken.lookup(hashed_verification_code).exists?
                   else
                     EmailAccessToken.lookup(hashed_verification_code).exists?
                   end

      unless valid_code
        errors.add(:verification_code, I18n.t("views.ctc.questions.verification.error_message"))
      end

      valid_code.present?
    end

    def save
      verification_attribute = contact_method.to_s + "_verified_at"
      @intake.touch(verification_attribute)
    end

    private

    def contact_method
      @intake.sms_notification_opt_in_yes? ? :sms_phone_number : :email_address
    end
  end
end