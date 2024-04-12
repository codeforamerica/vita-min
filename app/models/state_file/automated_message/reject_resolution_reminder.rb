module StateFile::AutomatedMessage
  class RejectResolutionReminder < BaseAutomatedMessage

    def self.name
      'messages.state_file.reject_resolution_reminder'.freeze
    end

    def self.send_only_once?
      true
    end

    def sms_body(**args)
      I18n.t("messages.state_file.reject_resolution_reminder.sms", **args)
    end

    def email_subject(**args)
      I18n.t("messages.state_file.reject_resolution_reminder.email.subject", **args)
    end

    def email_body(**args)
      I18n.t("messages.state_file.reject_resolution_reminder.email.body", **args)
    end
  end
end