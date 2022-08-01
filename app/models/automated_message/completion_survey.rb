module AutomatedMessage
  class CompletionSurvey < AutomatedMessage
    SENT_AT_COLUMN = :completion_survey_sent_at
    RELEVANT_STATES = ["file_accepted", "file_rejected", "file_not_filing", "file_mailed"]

    def self.clients_to_survey
      Client.where(
        id: TaxReturnTransition.where(to_state: RELEVANT_STATES)
            .includes(tax_return: { client: :intake })
            .where("tax_return_transitions.created_at < ?", 1.day.ago)
            .where("tax_return_transitions.created_at > ?", Date.new(2022, 7, 25))
            .where('intakes.type' => 'Intake::GyrIntake')
            .where(client: { SENT_AT_COLUMN => nil })
            .pluck("tax_returns.client_id")
      )
    end

    def self.name
      'messages.surveys.completion'.freeze
    end

    def self.send_only_once?
      true
    end

    def self.survey_link(client)
      is_drop_off_client = client.tax_returns.pluck(:service_type).any? "drop_off"
      survey_code = is_drop_off_client ? "SV_1Ch7S3rTLOgzbFk" : "SV_2uCOhUGqxJdG8Au"
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
