module Portal
  class RequestClientLoginForm < Form
    attr_accessor :email_address, :sms_phone_number

    before_validation :normalize_phone_number
    before_validation :strip_email
    validates :email_address, 'valid_email_2/email': { mx: true }
    validates :sms_phone_number, allow_blank: true, e164_phone: true
    validate :phone_number_or_email_address

    private

    def normalize_phone_number
      self.sms_phone_number = PhoneParser.normalize(sms_phone_number) if sms_phone_number.present?
    end

    def strip_email
      self.email_address = email_address.strip if email_address.present?
    end

    def phone_number_or_email_address
      if sms_phone_number.blank? && email_address.blank?
        errors.add(:email_address, I18n.t("forms.errors.need_one_communication_method"))
      end

      if sms_phone_number.present? && email_address.present?
        errors.add(:email_address, I18n.t("forms.errors.need_exactly_one_communication_method"))
      end
    end
  end
end
