module AutomatedMessage
  class SaveCtcLetter < AutomatedMessage
    def self.name
      'messages.save_ctc_letter'.freeze
    end

    def self.send_only_once?
      true
    end

    def sms_body(*args)
      I18n.t("messages.save_ctc_letter.sms", *args)
    end

    def email_subject(*args)
      I18n.t("messages.save_ctc_letter.email.subject", *args)
    end

    def email_body(locale: nil, body_args: {})
      I18n.t("messages.save_ctc_letter.email.body", locale: locale, **body_args)
    end
  end
end