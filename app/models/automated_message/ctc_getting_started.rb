module AutomatedMessage
  class CtcGettingStarted < AutomatedMessage
    def self.name
      'messages.ctc_getting_started'.freeze
    end

    def self.send_only_once?
      true
    end

    def sms_body(*args)
      I18n.t("messages.ctc_getting_started.sms", *args)
    end

    def email_subject(*args)
      I18n.t("messages.ctc_getting_started.email.subject", *args)
    end

    def email_body(*args)
      I18n.t("messages.ctc_getting_started.email.body", *args)
    end
  end
end
