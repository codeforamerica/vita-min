module StateFile::AutomatedMessage
  class IssueResolved < BaseAutomatedMessage

    def self.name
      'messages.state_file.issue_resolved'.freeze
    end

    def email_subject(**args)
      I18n.t("messages.state_file.issue_resolved.email.subject", **args)
    end

    def email_body(**args)
      I18n.t("messages.state_file.issue_resolved.email.body", **args)
    end

    def sms_body(**args)
      I18n.t("messages.state_file.issue_resolved.sms", **args)
    end
  end
end