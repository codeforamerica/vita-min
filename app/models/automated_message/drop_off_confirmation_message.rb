module AutomatedMessage
  class DropOffConfirmationMessage
    def self.name
      'drop_off_confirmation_message'.freeze
    end

    def sms_body(*args)
      I18n.t("drop_off_confirmation_message.sms", *args)
    end

    def email_subject(*args)
      I18n.t("drop_off_confirmation_message.email.subject", *args)
    end

    def email_body(*args)
      I18n.t("drop_off_confirmation_message.email.body", *args)
    end
  end
end
