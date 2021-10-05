module AutomatedMessage
  class ClosingSoon < AutomatedMessage

    def self.name
      'messages.closing_soon'.freeze
    end

    def self.send_only_once?
      true
    end

    def sms_body(**args)
      I18n.t("messages.closing_soon.sms", **args)
    end

    def email_subject(**args)
      I18n.t("messages.closing_soon.email.subject", **args)
    end

    def email_body(**args)
      I18n.t("messages.closing_soon.email.body", **args)
    end
  end
end
