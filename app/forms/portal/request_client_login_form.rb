module Portal
  class RequestClientLoginForm < Form
    attr_accessor :email_address, :phone_number

    before_validation :normalize_phone_number
    validates :email_address, 'valid_email_2/email': true
    validates :phone_number, allow_blank: true, phone: true, format: { with: /\A\+1[0-9]{10}\z/ }
    validate :phone_number_or_email_address

    private

    def normalize_phone_number
      self.phone_number = PhoneParser.normalize(phone_number) if phone_number.present?
    end

    def phone_number_or_email_address
      if phone_number.blank? && email_address.blank?
        errors.add(:email_address, I18n.t("forms.errors.need_one_communication_method"))
      end
    end
  end
end