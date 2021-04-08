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
        :email_notification_opt_in,
        :state_of_residence

    before_validation do
      self.sms_phone_number = PhoneParser.normalize(sms_phone_number)
      self.phone_number = PhoneParser.normalize(phone_number)
      self.preferred_name = preferred_name.presence || "#{primary_first_name} #{primary_last_name}"
    end

    validates :email_address, 'valid_email_2/email': true
    validates :phone_number, allow_blank: true, e164_phone: true
    validates :sms_phone_number, allow_blank: true, e164_phone: true
    validates_presence_of :email_address, if: -> { opted_in_email? }
    validates_presence_of :sms_phone_number, if: -> { opted_in_sms? }
    validates_presence_of :primary_first_name
    validates_presence_of :primary_last_name
    validates :state_of_residence, inclusion: { in: States.keys }
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
