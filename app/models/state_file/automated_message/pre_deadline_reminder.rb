module StateFile::AutomatedMessage
  class PreDeadlineReminder < BaseAutomatedMessage

    def self.name
      'messages.state_file.pre_deadline_reminder'.freeze
    end

    def self.after_transition_notification?
      false
    end

    def self.send_only_once?
      true
    end

    def sms_body(**args)
      I18n.t("messages.state_file.pre_deadline_reminder.sms", **args)
    end

    def email_subject(**args)
      I18n.t("messages.state_file.pre_deadline_reminder.email.subject", **args)
    end

    def email_body(**args)
      I18n.t("messages.state_file.pre_deadline_reminder.email.body", **args)
    end
  end
end
