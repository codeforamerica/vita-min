module StateFile
  class RequestIntakeLoginForm < Portal::RequestClientLoginForm

    def filter_records(intake_class)
      if email_address.present?
        intake_class.where(email_address: email_address).where.not(email_address_verified_at: nil)
      else
        intake_class.where(phone_number: sms_phone_number).where.not(phone_number_verified_at: nil)
      end
    end

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
