module Portal
  class RequestClientLoginForm < Form
    attr_accessor :phone_number, :email_address

    validates :phone_number, phone: true, allow_blank: true, format: { with: /\A\+1[0-9]{10}\z/ }
    validates :email_address, 'valid_email_2/email': true
    validate :phone_number_or_email_address

    def phone_number_or_email_address
      if phone_number.blank? && email_address.blank?
        errors.add(:email_address, I18n.t("forms.errors.need_one_communication_method"))
      end
    end
  end
end