module AutomatedMessage
  class NotReadyReminder

    def self.name
      'messages.not_ready_reminder'.freeze
    end

    def sms_body(*args)
      I18n.t("messages.not_ready_reminder.sms", *args)
    end

    def email_subject(*args)
      I18n.t("messages.not_ready_reminder.email.subject", *args)
    end

    def email_body(*args)
      I18n.t("messages.not_ready_reminder.email.body", *args)
    end
  end
end
