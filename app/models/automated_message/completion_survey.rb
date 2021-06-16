module AutomatedMessage
  class CompletionSurvey
    def self.name
      'messages.surveys.completion'.freeze
    end

    def sms_body(*args)
      I18n.t("messages.surveys.completion.sms", *args)
    end

    def email_subject(*args)
      I18n.t("messages.surveys.completion.email.subject", *args)
    end

    def email_body(*args)
      I18n.t("messages.surveys.completion.email.body", *args)
    end
  end
end
