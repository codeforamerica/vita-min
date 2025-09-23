module StateFile::AutomatedMessage
  class DeadlineReminderToday < BaseAutomatedMessage

    def self.name
      'messages.state_file.deadline_reminder_today'.freeze
    end

    def self.after_transition_notification?
      false
    end

    def self.send_only_once?
      false
    end

    def sms_body(**args)
      I18n.t("messages.state_file.deadline_reminder_today.sms", **args)
    end

    def email_subject(**args)
      I18n.t("messages.state_file.deadline_reminder_today.email.subject", **args)
    end

    def email_body(**args)
      I18n.t("messages.state_file.deadline_reminder_today.email.body", **args)
    end
  end
end
