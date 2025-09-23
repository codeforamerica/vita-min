module StateFile::AutomatedMessage
  class DeadlineReminderTomorrow < BaseAutomatedMessage

    def self.name
      'messages.state_file.deadline_reminder_tomorrow'.freeze
    end

    def sms_body(**args)
      I18n.t("messages.state_file.deadline_reminder_tomorrow.sms", **args)
    end

    def email_subject(**args)
      I18n.t("messages.state_file.deadline_reminder_tomorrow.email.subject", **args)
    end

    def email_body(**args)
      I18n.t("messages.state_file.deadline_reminder_tomorrow.email.body", **args)
    end
  end
end
