module AutomatedMessage
  class ContactInfoChange < AutomatedMessage
    def self.name
      'messages.contact_info_change'.freeze
    end

    def sms_body(*args)
      I18n.t("messages.contact_info_change.sms", *args)
    end

    def email_subject(*args)
      I18n.t("messages.contact_info_change.email.subject", *args)
    end

    def email_body(*args)
      I18n.t("messages.contact_info_change.email.body", *args)
    end
  end
end
