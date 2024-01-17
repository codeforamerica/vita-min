module AutomatedMessage::StateFile
  # TODO: See if we can get rid of this pseudo-abstract superclass, it doesn't do anything
  class Welcome < AutomatedMessage::AutomatedMessage
    def self.name
      'state_file_welcome'
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