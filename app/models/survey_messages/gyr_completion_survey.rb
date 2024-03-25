module SurveyMessages
  class GyrCompletionSurvey
    SENT_AT_COLUMN = :completion_survey_sent_at
    RELEVANT_STATES = %w[file_accepted file_mailed]

    def self.clients_to_survey(now)
      Client.includes(:intake, tax_returns: :tax_return_transitions)
        .where(SENT_AT_COLUMN => nil)
        .where(intake: { type: "Intake::GyrIntake" })
        .where.not(id: Client.has_active_tax_returns)
        .where(
          tax_returns: {
            service_type: "online_intake",
            tax_return_transitions: TaxReturnTransition
              .where(to_state: RELEVANT_STATES)
              .where(most_recent: true)
              .where(created_at: (now - 30.days)...(now - 1.day))
          }
        )
    end

    def self.enqueue_surveys(now)
      clients_to_survey(now).find_each { |client| SendClientCompletionSurveyJob.perform_later(client) }
    end

    def self.name
      'messages.surveys.completion'.freeze
    end

    def self.send_only_once?
      true
    end

    def self.survey_link(client)
      "https://codeforamerica.co1.qualtrics.com/jfe/form/SV_0Gu4MGVVAM8p1NY?ExternalDataReference=#{client.id}"
    end

    def sms_body(**args)
      I18n.t("messages.surveys.completion.sms", **args)
    end

    def email_subject(**args)
      I18n.t("messages.surveys.completion.email.subject", **args)
    end

    def email_body(**args)
      I18n.t("messages.surveys.completion.email.body", **args)
    end
  end
end
