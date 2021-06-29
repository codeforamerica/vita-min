module AutomatedMessage
  class SuccessfulSubmissionOnlineIntake
    def self.name
      'messages.successful_submission_online_intake'.freeze
    end

    def sms_body(*args)
      I18n.t("messages.successful_submission_online_intake.sms", *args)
    end

    def email_subject(*args)
      I18n.t("messages.successful_submission_online_intake.email.subject", *args)
    end

    def email_body(*args)
      I18n.t("messages.successful_submission_online_intake.email.body", *args)
    end
  end
end
