module AutomatedMessage
  class SuccessfulSubmissionOnlineIntake < AutomatedMessage
    def self.name
      'messages.successful_submission_online_intake'.freeze
    end

    def sms_body(locale: nil, body_args: {})
      I18n.t("messages.successful_submission_online_intake.sms", locale: locale, **body_args)
    end

    def email_subject(locale: nil, body_args: {})
      I18n.t("messages.successful_submission_online_intake.email.subject", locale: locale, **body_args)
    end

    def email_body(locale: nil, body_args: {})
      I18n.t("messages.successful_submission_online_intake.email.body", locale: locale, **body_args)
    end
  end
end
