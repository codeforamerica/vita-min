module StateFile::AutomatedMessage
  class StillProcessing < BaseAutomatedMessage

    def self.name
      'messages.state_file.still_processing'.freeze
    end

    def self.after_transition_notification?
      true
    end

    def self.send_only_once?
      true
    end

    def sms_body(**args)
      I18n.t("messages.state_file.still_processing.sms", **args)
    end

    def email_subject(**args)
      I18n.t("messages.state_file.still_processing.email.subject", **args)
    end

    def email_body(**args)
      I18n.t("messages.state_file.still_processing.email.body", **args)
    end
  end
end