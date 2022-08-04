module SurveyMessages
  class GyrInProgressSurvey
    SENT_AT_COLUMN = :in_progress_survey_sent_at

    def self.clients_to_survey(now)
      Client.
        where(SENT_AT_COLUMN => nil)
        .where("consented_to_service_at < ?", now - 10.days)
        .includes(:tax_returns).where(tax_returns: { current_state: "intake_in_progress" })
        .includes(:intake).where(intake: { type: "Intake::GyrIntake" })
        .includes(:incoming_text_messages).where(incoming_text_messages: { client_id: nil })
        .includes(:incoming_emails).where(incoming_emails: { client_id: nil })
        .includes(:documents).where("documents.client_id IS NULL OR documents.created_at < (interval '1 day' + clients.created_at)")
    end

    def self.enqueue_surveys(now)
      clients_to_survey(now).find_each { |client| SendClientInProgressSurveyJob.perform_later(client) }
    end

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
