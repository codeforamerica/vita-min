module StateFile::AutomatedMessage
  class AcceptedOwe < BaseAutomatedMessage

    def self.name
      'messages.state_file.accepted_owe'.freeze
    end

    def self.send_only_once?
      true
    end

    def sms_body(**args)
      I18n.t("messages.state_file.accepted_owe.sms", **args)
    end

    def email_subject(**args)
      I18n.t("messages.state_file.accepted_owe.email.subject", **args)
    end

    def email_body(**args)
      I18n.t("messages.state_file.accepted_owe.email.body", **args)
    end
  end
end