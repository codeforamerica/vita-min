module Hub
  class ClientForm < Form
    include FormAttributes
    set_attributes_for :intake,
        :sms_phone_number,
        :phone_number,
        :preferred_name,
        :primary_first_name,
        :primary_last_name,
        :email_address,
        :preferred_interview_language,
        :sms_notification_opt_in,
        :email_notification_opt_in

    before_validation do
      self.sms_phone_number = PhoneParser.normalize(sms_phone_number)
      self.phone_number = PhoneParser.normalize(phone_number)
      self.preferred_name = preferred_name.presence || "#{primary_first_name} #{primary_last_name}"
    end

    validates :primary_first_name, presence: true, allow_blank: false
    validates :primary_last_name, presence: true, allow_blank: false
    validates :phone_number, allow_blank: true, phone: true
    validates :sms_phone_number, phone: true, if: -> { sms_phone_number.present? }
    validates :sms_phone_number, presence: true, allow_blank: false, if: -> { opted_in_sms? }
    validates :email_address, presence: true, allow_blank: false, 'valid_email_2/email': true
    validates :preferred_interview_language, presence: true, allow_blank: false
    validate :at_least_one_contact_method

    private

    def opted_in_sms?
      sms_notification_opt_in == "yes"
    end

    def opted_in_email?
      email_notification_opt_in == "yes"
    end

    def at_least_one_contact_method
      unless opted_in_email? || opted_in_sms?
        errors.add(:communication_preference, I18n.t("forms.errors.need_one_communication_method"))
      end
    end
  end
end