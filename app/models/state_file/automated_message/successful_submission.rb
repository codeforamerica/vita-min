module StateFile::AutomatedMessage
  class SuccessfulSubmission < BaseAutomatedMessage

    def self.name
      'messages.state_file.successful_submission'.freeze
    end

    def self.after_transition_notification?
      true
    end

    def self.send_only_once?
      true
    end

    def sms_body(**args)
      I18n.t("messages.state_file.successful_submission.sms", **args)
    end

    def email_subject(**args)
      I18n.t("messages.state_file.successful_submission.email.subject", **args)
    end

    def email_body(**args)
      I18n.t("messages.state_file.successful_submission.email.body", **args)
    end
  end
end