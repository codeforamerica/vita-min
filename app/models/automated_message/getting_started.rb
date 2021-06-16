module AutomatedMessage
  class GettingStarted
    def self.name
      'messages.getting_started'.freeze
    end

    def sms_body(*args)
      I18n.t("messages.getting_started.sms", *args)
    end

    def email_subject(*args)
      I18n.t("messages.getting_started.email.subject", *args)
    end

    def email_body(*args)
      I18n.t("messages.getting_started.email.body", *args)
    end
  end
end
