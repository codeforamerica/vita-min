module StateFile
  class RequestIntakeLoginForm < Portal::RequestClientLoginForm
    private

    def phone_number_or_email_address
      if sms_phone_number.blank? && email_address.blank?
        message = I18n.t("errors.messages.blank")
        errors.add(:email_address, message)
        errors.add(:sms_phone_number, message)
      end
    end
  end
end