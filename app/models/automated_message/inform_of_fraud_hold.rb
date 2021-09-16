module AutomatedMessage
  class InformOfFraudHold
    def self.name
      'messages.fraud_hold'.freeze
    end

    def sms_body(*args)
      I18n.t("messages.fraud_hold.sms", *args)
    end

    def email_subject(*args)
      I18n.t("messages.fraud_hold.email.subject", *args)
    end

    def email_body(*args)
      I18n.t("messages.fraud_hold.email.body", *args)
    end
  end
end
