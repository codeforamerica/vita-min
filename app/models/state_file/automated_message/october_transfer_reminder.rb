module StateFile::AutomatedMessage
  class OctoberTransferReminder < BaseAutomatedMessage

    def self.after_transition_notification?
      false
    end

    def self.send_only_once?
      true
    end

    def self.name
      'messages.state_file.october_transfer_reminder'.freeze
    end

    def sms_body(**args)
      I18n.t("messages.state_file.october_transfer_reminder.sms", **args)
    end

    def email_subject(**args)
      I18n.t("messages.state_file.october_transfer_reminder.email.subject", **args)
    end

    def email_body(**args)
      I18n.t("messages.state_file.october_transfer_reminder.email.body", **args)
    end
  end
end
