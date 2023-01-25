module AutomatedMessage
  class InProgress < ::AutomatedMessage::AutomatedMessage

    def self.clients_to_message(now)
      Client
        .where("consented_to_service_at <= ?", now - 30.minutes)
        .includes(:tax_returns).where(tax_returns: { current_state: "intake_in_progress" })
    end

    def self.enqueue_surveys(now)
      clients_to_message(now).find_each { |client| SendClientInProgressMessageJob.perform_later(client) }
    end

    def self.name
      'messages.in_progress'.freeze
    end

    def self.survey_link(client)
      nil
    end

    def self.send_only_once?
      true
    end

    def sms_body(*args)
      I18n.t("messages.in_progress.sms", *args)
    end

    def email_subject(*args)
      I18n.t("messages.in_progress.email.subject", *args)
    end

    def email_body(*args)
      I18n.t("messages.in_progress.email.body", *args)
    end
  end
end
