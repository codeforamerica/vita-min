module AutomatedMessage
  class DocumentsReminderLink
    def self.name
      'documents.reminder_link'.freeze
    end

    def initialize(doc_type: nil)
      @doc_type = doc_type
    end

    def email_body(args = {})
      I18n.t("documents.reminder_link.email.body", args.merge(doc_type: @doc_type))
    end

    def email_subject(*args)
      I18n.t("documents.reminder_link.email.subject", *args)
    end

    def sms_body(args = {})
      I18n.t("documents.reminder_link.sms", args.merge(doc_type: @doc_type))
    end
  end
end
