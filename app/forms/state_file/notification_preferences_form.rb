module StateFile
  class NotificationPreferencesForm < QuestionsForm
    set_attributes_for :intake, :sms_notification_opt_in, :email_notification_opt_in, :phone_number, :email_address
    before_validation :normalize_phone_numbers

    validates :phone_number, e164_phone: true, presence: true, if: -> { sms_notification_opt_in == "yes" && !@intake.phone_number.present? }
    validates :email_address, 'valid_email_2/email': true, presence: true, if: -> { email_notification_opt_in == "yes" && !@intake.email_address.present? }
    validate :at_least_one_selected

    def save
      attributes_to_exclude = []
      attributes_to_exclude << :email_address if @intake.email_address.present?
      attributes_to_exclude << :phone_number if @intake.phone_number.present?
      is_first_time_setup = @intake.sms_notification_opt_in == "unfilled" && @intake.email_notification_opt_in == "unfilled"

      @intake.update(attributes_for(:intake).except(*attributes_to_exclude))

      if is_first_time_setup
        messaging_service = StateFile::MessagingService.new(
          locale: I18n.locale,
          message: StateFile::AutomatedMessage::Welcome,
          intake: @intake,
          sms: sms_notification_opt_in == "yes",
          email: email_notification_opt_in == "yes",
          body_args: { intake_id: @intake.id }
        )
        messaging_service.send_message(require_verification: false)
      end
    end

    private

    def at_least_one_selected
      unless attributes_for(:intake).values_at(:sms_notification_opt_in, :email_notification_opt_in).any? { |value| value == "yes" }
        errors.add(:opt_in, I18n.t("state_file.questions.notification_preferences.form.at_least_one"))
      end
    end

    def normalize_phone_numbers
      self.phone_number = PhoneParser.normalize(phone_number) if phone_number.present?
    end
  end
end
