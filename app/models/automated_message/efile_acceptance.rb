module AutomatedMessage
  class EfileAcceptance < AutomatedMessage

    def self.name
      'messages.efile.acceptance'.freeze
    end

    def sms_body(*args)
      I18n.t("messages.efile.acceptance.sms", *args)
    end

    def email_subject(*args)
      I18n.t("messages.efile.acceptance.email.subject", *args)
    end

    def email_body(*args)
      I18n.t("messages.efile.acceptance.email.body", *args)
    end
  end
end
