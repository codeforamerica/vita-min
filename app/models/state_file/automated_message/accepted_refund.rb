module StateFile::AutomatedMessage
  class AcceptedRefund < BaseAutomatedMessage

    def self.name
      'messages.state_file.accepted_refund'.freeze
    end

    def self.send_only_once?
      true
    end

    def sms_body(**args)
      I18n.t("messages.state_file.accepted_refund.sms", **args)
    end

    def email_subject(**args)
      I18n.t("messages.state_file.accepted_refund.email.subject", **args)
    end

    def email_body(**args)
      I18n.t("messages.state_file.accepted_refund.email.body", **args)
    end
  end
end