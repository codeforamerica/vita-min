module AutomatedMessage
  class DocumentsReminderLink < AutomatedMessage
    def self.name
      'documents.reminder_link'.freeze
    end

    def email_body(locale: nil, body_args: {})
      I18n.t("documents.reminder_link.email.body", locale: locale, **body_args)
    end

    def email_subject(locale: nil, body_args: {})
      I18n.t("documents.reminder_link.email.subject", locale: locale, **body_args)
    end

    def sms_body(locale: nil, body_args: {})
      I18n.t("documents.reminder_link.sms", locale: locale, **body_args)
    end
  end
end
