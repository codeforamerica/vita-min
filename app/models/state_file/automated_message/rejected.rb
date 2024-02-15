module StateFile::AutomatedMessage
  class Rejected < BaseAutomatedMessage

    def self.name
      'messages.state_file.rejected'.freeze
    end

    def self.send_only_once?
      # true
      false
    end

    def sms_body(**args)
      I18n.t("messages.state_file.rejected.sms", **args)
    end

    def email_subject(**args)
      I18n.t("messages.state_file.rejected.email.subject", **args)
    end

    def email_body(**args)
      I18n.t("messages.state_file.rejected.email.body", **args)
    end
  end
end