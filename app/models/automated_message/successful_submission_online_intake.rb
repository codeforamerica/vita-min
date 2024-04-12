module AutomatedMessage
  class SuccessfulSubmissionOnlineIntake < AutomatedMessage
    def self.name
      'messages.successful_submission_online_intake'.freeze
    end

    def sms_body(**args)
      I18n.t("messages.successful_submission_online_intake.sms", **args.merge(docs_day_params))
    end

    def email_subject(**args)
      I18n.t("messages.successful_submission_online_intake.email.subject", **args)
    end

    def email_body(**args)
      I18n.t("messages.successful_submission_online_intake.email.body", **args.merge(docs_day_params))
    end

    private

    def docs_day_params
      doc_date = app_time.before?(Rails.configuration.tax_deadline) ? DateTime.parse('2024-04-01') : Rails.configuration.end_of_docs.to_date
      {
        end_of_docs_date: I18n.l(doc_date, format: :medium, locale: I18n.locale)
      }
    end
  end
end
