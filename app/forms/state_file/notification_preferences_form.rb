module StateFile
  class NotificationPreferencesForm < QuestionsForm
    set_attributes_for :intake, :sms_notification_opt_in, :email_notification_opt_in, :phone_number
    before_validation :normalize_phone_numbers

    validates :phone_number, allow_blank: true, e164_phone: true, if: -> { attributes_for(:intake)[:sms_notification_opt_in] == "yes" }

    def save
      @intake.update(attributes_for(:intake))
    end

    private

    def normalize_phone_numbers
      # self.phone_number = PhoneParser.normalize(phone_number) if phone_number.present?
    end
  end
end
