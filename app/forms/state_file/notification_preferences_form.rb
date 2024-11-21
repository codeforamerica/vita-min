module StateFile
  class NotificationPreferencesForm < QuestionsForm
    set_attributes_for :intake, :sms_notification_opt_in, :email_notification_opt_in, :phone_number

    validates :phone_number, allow_blank: true, e164_phone: true, if: -> { attributes_for(:intake)[:sms_notification_opt_in].present? }

    def save
      @intake.update(attributes_for(:intake))
    end
  end
end
