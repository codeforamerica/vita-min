module StateFile::NotificationMessages
  class Welcome
    def self.sms_body(**args)
      I18n.t("messages.state_file.welcome.sms", **args)
    end

    def self.email_subject(**args)
      I18n.t("messages.state_file.welcome.email.subject", **args)
    end

    def self.email_body(**args)
      I18n.t("messages.state_file.welcome.email.body", **args)
    end
  end
end