module AutomatedMessage
  class UnmonitoredReplies < AutomatedMessage
    def self.name
      'messages.unmonitored_replies'.freeze
    end

    def sms_body(*args)
      I18n.t("messages.unmonitored_replies.sms.body", *args)
    end

    def email_subject(*args)
      I18n.t("messages.unmonitored_replies.email.subject", *args)
    end

    def email_body(*args)
      I18n.t("messages.unmonitored_replies.email.body", *args)
    end
  end
end
