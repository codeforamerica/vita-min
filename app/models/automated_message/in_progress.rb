module AutomatedMessage
  class InProgress < ::AutomatedMessage::AutomatedMessage
    SENT_AT_COLUMN = :in_progress_survey_sent_at

    def self.clients_to_message(now)
      Client
        .where(in_progress_survey_sent_at: nil)
        .includes(:intake).where(intake: { type: "Intake::GyrIntake" })
        .where("consented_to_service_at BETWEEN ? AND ? ", now - 24.hours, now - 30.minutes)
        .includes(:tax_returns).where(tax_returns: { current_state: %w[intake_in_progress intake_needs_doc_help] })
    end

    def self.enqueue_messages(now)
      clients_to_message(now).find_each { |client| SendClientInProgressMessageJob.perform_later(client) }
    end

    def self.name
      'messages.in_progress'.freeze
    end

    def self.survey_link(_client)
      nil
    end

    def self.send_only_once?
      true
    end

    def self.require_client_account?
      true
    end

    def sms_body(**args)
      I18n.t("messages.in_progress.sms.body", **args)
    end

    def email_subject(**args)
      I18n.t("messages.in_progress.email.subject", **args)
    end

    def email_body(**args)
      I18n.t("messages.in_progress.email.body", **args)
    end
  end
end
