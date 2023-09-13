module SurveyMessages
  class CtcExperienceSurvey
    SENT_AT_COLUMN = :ctc_experience_survey_sent_at
    RELEVANT_STATES = %w[file_accepted file_mailed]
    FOUR_DAY_STATES = [:file_not_filing]
    SEVEN_DAY_STATES = [:file_hold]

    def self.clients_to_survey(now)
      Client.includes(:intake, tax_returns: :tax_return_transitions)
        .where(SENT_AT_COLUMN => nil)
        .where(intake: { type: "Intake::CtcIntake" })
        .where(
          tax_returns: {
            service_type: "online_intake",
            tax_return_transitions: TaxReturnTransition.where(to_state: RELEVANT_STATES, most_recent: true, created_at: (now - 30.days)...(now - 1.day)).or(
              TaxReturnTransition.where(to_state: FOUR_DAY_STATES, most_recent: true, created_at: (now - 30.days)...(now - 4.days)).or(
                TaxReturnTransition.where(to_state: SEVEN_DAY_STATES, most_recent: true, created_at: (now - 30.days)...(now - 7.days))))
          }
        )
    end

    def self.enqueue_surveys(now)
      clients_to_survey(now).find_each { |client| SendClientCtcExperienceSurveyJob.perform_later(client) }
    end

    def self.name
      'messages.surveys.ctc_experience'.freeze
    end

    def self.send_only_once?
      true
    end

    def self.survey_link(client)
      ctc_not_filing_status = client.intake.default_tax_return&.current_state == "file_not_filing" ? 'TRUE' : 'FALSE'

      "https://codeforamerica.co1.qualtrics.com/jfe/form/SV_4Mi9xc5m8BUNmyW?&ExternalDataReference=#{client.id}&ctcNotFiling=#{ctc_not_filing_status}&expGroup=#{client.ctc_experience_survey_variant}"
    end

    def sms_body(**args)
      I18n.t("messages.surveys.ctc_experience.sms", **args)
    end

    def email_subject(**args)
      I18n.t("messages.surveys.ctc_experience.email.subject", **args)
    end

    def email_body(**args)
      I18n.t("messages.surveys.ctc_experience.email.body", **args)
    end
  end
end
