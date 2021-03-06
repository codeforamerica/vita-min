module AutomatedMessage
  class InProgressSurvey
    def self.name
      'messages.surveys.in_progress'.freeze
    end

    def sms_body(*args)
      I18n.t("messages.surveys.in_progress.sms", *args)
    end

    def email_subject(*args)
      I18n.t("messages.surveys.in_progress.email.subject", *args)
    end

    def email_body(*args)
      I18n.t("messages.surveys.in_progress.email.body", *args)
    end
  end
end
