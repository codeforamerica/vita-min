module StateFile
  class NotificationPreferencesForm < QuestionsForm
    set_attributes_for :intake, :sms_notification_opt_in, :email_notification_opt_in, :phone_number
    before_validation :normalize_phone_numbers

    validates :phone_number, e164_phone: true, if: -> { attributes_for(:intake)[:sms_notification_opt_in] == "yes" }
    validate :at_least_one_selected

    def save
      @intake.update(attributes_for(:intake))
    end

    private

    def at_least_one_selected
      unless attributes_for(:intake).values_at(:sms_notification_opt_in, :email_notification_opt_in).any? { |value| value == "yes" }
        errors.add(:sms_notification_opt_in, I18n.t("state_file.questions.notification_preferences.form.at_least_one"))
      end
    end

    def normalize_phone_numbers
      self.phone_number = PhoneParser.normalize(phone_number) if phone_number.present?
    end
  end
end
