module AutomatedMessage
  class VerificationAttemptDenied < AutomatedMessage
    def self.name
      'messages.verification_attempt_denied'.freeze
    end

    def sms_body(*args)
      I18n.t("messages.verification_attempt_denied.sms", *args)
    end

    def email_subject(*args)
      I18n.t("messages.verification_attempt_denied.email.subject", *args)
    end

    def email_body(*args)
      I18n.t("messages.verification_attempt_denied.email.body", *args)
    end
  end
end
