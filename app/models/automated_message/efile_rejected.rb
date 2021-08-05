module AutomatedMessage
  class EfileRejected

    def self.name
      'messages.efile.rejected'.freeze
    end

    def sms_body(**args)
      I18n.t("messages.efile.rejected.sms", **args, error_code: @error_code, error_message: @error_message)
    end

    def email_subject(**args)
      I18n.t("messages.efile.rejected.email.subject", **args)
    end

    def email_body(**args)
      I18n.t("messages.efile.rejected.email.body", **args)
    end
  end
end
