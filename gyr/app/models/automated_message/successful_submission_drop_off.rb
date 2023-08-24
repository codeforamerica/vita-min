module AutomatedMessage
  class SuccessfulSubmissionDropOff < AutomatedMessage
    def self.name
      'messages.successful_submission_drop_off'.freeze
    end

    def self.send_only_once?
      true
    end

    def sms_body(**args)
      I18n.t("messages.successful_submission_drop_off.sms", **args)
    end

    def email_subject(**args)
      I18n.t("messages.successful_submission_drop_off.email.subject", **args)
    end

    def email_body(**args)
      I18n.t("messages.successful_submission_drop_off.email.body", **args)
    end
  end
end
