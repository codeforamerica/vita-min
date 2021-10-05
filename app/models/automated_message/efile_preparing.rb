module AutomatedMessage
  class EfilePreparing < AutomatedMessage

    def self.name
      'messages.efile.preparing'.freeze
    end

    def self.send_only_once?
      true
    end

    def sms_body(*args)
      I18n.t("messages.efile.preparing.sms", *args)
    end

    def email_subject(*args)
      I18n.t("messages.efile.preparing.email.subject", *args)
    end

    def email_body(*args)
      I18n.t("messages.efile.preparing.email.body", *args)
    end
  end
end
