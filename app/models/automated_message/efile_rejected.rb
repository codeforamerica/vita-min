module AutomatedMessage
  class EfileRejected

    def initialize(error_code:, error_message:)
      @error_code = error_code || "Unknown"
      @error_message = error_message || "Unknown"
    end

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
      I18n.t("messages.efile.rejected.email.body", **args, error_code: @error_code, error_message: @error_message)
    end
  end
end
