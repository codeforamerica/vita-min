module StateFile::AutomatedMessage
  class DfTransferIssueMessage < BaseAutomatedMessage
    def self.name
      'messages.state_file.df_transfer_issue_message'.freeze
    end

    def self.after_transition_notification?
      false
    end

    def self.send_only_once?
      true
    end

    def sms_body(state_code:)
      I18n.t("messages.state_file.df_transfer_issue_message.sms", state_code: state_code)
    end

    def email_subject(state_code:)
      I18n.t("messages.state_file.df_transfer_issue_message.email.subject", state_code: state_code)
    end

    def email_body(state_code:)
      I18n.t("messages.state_file.df_transfer_issue_message.email.body", state_code: state_code)
    end
  end
end
