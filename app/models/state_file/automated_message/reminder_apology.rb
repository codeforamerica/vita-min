module StateFile::AutomatedMessage
  class ReminderApology < BaseAutomatedMessage

    def self.name
      'messages.state_file.reminder_apology'.freeze
    end

    def self.after_transition_notification?
      false
    end

    def self.send_only_once?
      true
    end

    def email_subject(**args)
      I18n.t("messages.state_file.reminder_apology.email.subject", **args)
    end

    def email_body(**args)
      I18n.t("messages.state_file.reminder_apology.email.body", **args)
    end
  end
end
