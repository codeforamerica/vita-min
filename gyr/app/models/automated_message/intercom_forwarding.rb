module AutomatedMessage
  class IntercomForwarding < AutomatedMessage
    def self.name
      'messages.intercom_forwarding'.freeze
    end

    def sms_body(**args)
      I18n.t("messages.intercom_forwarding.sms.body", **args)
    end

    def email_subject(**args)
      I18n.t("messages.intercom_forwarding.email.subject", **args)
    end

    def email_body(**args)
      I18n.t("messages.intercom_forwarding.email.body", **args)
    end
  end
end
