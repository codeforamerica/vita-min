module StateFile::AutomatedMessage
  class MonthlyFinishReturn < BaseAutomatedMessage

    def self.name
      'messages.state_file.monthly_finish_return'.freeze
    end

    def sms_body(**args)
      I18n.t("messages.state_file.monthly_finish_return.sms", **args)
    end

    def email_subject(**args)
      I18n.t("messages.state_file.monthly_finish_return.email.subject", **args)
    end

    def email_body(**args)
      I18n.t("messages.state_file.monthly_finish_return.email.body", **args)
    end
  end
end
