module AutomatedMessage
  class Welcome < AutomatedMessage
    def self.name
      'messages.welcome'.freeze
    end

    def self.send_only_once?
      true
    end

    def sms_body(**args)
      I18n.t("messages.welcome.sms", **args)
    end

    def email_subject(**args)
      I18n.t("messages.welcome.email.subject", **args)
    end

    def email_body(**args)
      I18n.t("messages.welcome.email.body", **args)
    end
  end
end
