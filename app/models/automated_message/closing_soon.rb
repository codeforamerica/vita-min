module AutomatedMessage
  class ClosingSoon < AutomatedMessage

    def self.name
      'messages.closing_soon'.freeze
    end

    def self.send_only_once?
      true
    end

    def self.require_client_account?
      true
    end

    def sms_body(locale: nil, body_args: {})
      I18n.t("messages.closing_soon.sms", locale: locale, **body_args)
    end

    def email_subject(locale: nil, body_args: {})
      I18n.t("messages.closing_soon.email.subject", locale: locale, **body_args)
    end

    def email_body(locale: nil, body_args: {})
      I18n.t("messages.closing_soon.email.body", locale: locale, **body_args)
    end
  end
end
