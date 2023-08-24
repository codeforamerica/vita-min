module AutomatedMessage
  class EfileFailed < AutomatedMessage

    def self.name
      'messages.efile.failed'.freeze
    end

    def sms_body(**args)
      I18n.t("messages.efile.failed.sms", **args)
    end

    def email_subject(**args)
      I18n.t("messages.efile.failed.email.subject", **args)
    end

    def email_body(**args)
      I18n.t("messages.efile.failed.email.body", **args)
    end
  end
end
