module AutomatedMessage
  class CtcExperienceSurvey < AutomatedMessage
    SENT_AT_COLUMN = :ctc_experience_survey_sent_at
    RELEVANT_STATES = %w[file_accepted file_not_filing file_mailed]

    def self.clients_to_survey
      Client.where(
        id: TaxReturnTransition.includes(tax_return: { client: :intake })
          .where(tax_return: { service_type: "online_intake" })
          .where(clients: { SENT_AT_COLUMN => nil })
          .where("tax_return_transitions.created_at < ?", 1.day.ago)
          .where("tax_return_transitions.created_at > ?", 30.days.ago)
          .where(intake: { type: "Intake::CtcIntake" })
          .where(to_state: RELEVANT_STATES).pluck("tax_return.client_id")
      )
    end

    def self.enqueue_surveys
      clients_to_survey.find_each { |client| SendClientCtcExperienceSurveyJob.perform_later(client) }
    end

    def self.name
      'messages.surveys.ctc_experience'.freeze
    end

    def self.send_only_once?
      true
    end

    def self.survey_link(client)
      ctc_not_filing_status = client.intake.default_tax_return.current_state == "file_not_filing" ? 'TRUE' : 'FALSE'

      "https://codeforamerica.co1.qualtrics.com/jfe/form/SV_4Mi9xc5m8BUNmyW?&ExternalDataReference=#{client.id}&ctcNotFiling=#{ctc_not_filing_status}&expGroup=#{client.ctc_experience_survey_variant}"
    end

    def sms_body(*args)
      I18n.t("messages.surveys.ctc_experience.sms", *args)
    end

    def email_subject(*args)
      I18n.t("messages.surveys.ctc_experience.email.subject", *args)
    end

    def email_body(*args)
      I18n.t("messages.surveys.ctc_experience.email.body", *args)
    end
  end
end
