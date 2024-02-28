module StateFile::AutomatedMessage
  class Welcome < BaseAutomatedMessage
    def self.name
      'messages.state_file.welcome'.freeze
    end

    def self.send_only_once?
      true
    end

    def sms_body(**args)
      I18n.t("messages.state_file.welcome.sms", **args)
    end

    def email_subject(**args)
      I18n.t("messages.state_file.welcome.email.subject", **args)
    end

    def email_body(**args)
      I18n.t("messages.state_file.welcome.email.body", **args)
    end
  end
end
