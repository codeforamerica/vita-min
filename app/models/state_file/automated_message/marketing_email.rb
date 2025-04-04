module StateFile::AutomatedMessage
  class MarketingEmail < BaseAutomatedMessage
    def self.name
      'messages.state_file.marketing_email'.freeze
    end

    def self.after_transition_notification?
      false
    end

    def self.send_only_once?
      true
    end

    def email_subject(**args)
      I18n.t("messages.state_file.marketing_email.subject", **args)
    end

    def email_body(**args)
      I18n.t("messages.state_file.marketing_email.body", **args)
    end
  end
end
