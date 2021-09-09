module AutomatedMessage
  class CompletionSurvey
    def self.name
      'messages.surveys.completion'.freeze
    end

    def self.survey_link(client)
      is_drop_off_client = client.tax_returns.pluck(:service_type).any? "drop_off"
      survey_code = is_drop_off_client ? "SV_ebtml6MMfhf8Vsa" : "SV_exiL2bLJx8GvjGC"
      "https://codeforamerica.co1.qualtrics.com/jfe/form/#{survey_code}?ExternalDataReference=#{client.id}"
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
