module AutomatedMessage
  class InProgressSurvey < AutomatedMessage
    def self.name
      'messages.surveys.in_progress'.freeze
    end

    def self.survey_link(client)
      "https://codeforamerica.co1.qualtrics.com/jfe/form/SV_9KwOYGguQ7L0y22?ExternalDataReference=#{client.id}"
    end

    def self.send_only_once?
      true
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
