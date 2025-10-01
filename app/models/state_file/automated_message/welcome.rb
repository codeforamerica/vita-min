module StateFile::AutomatedMessage
  class Welcome < BaseAutomatedMessage
    def self.name
      'messages.state_file.welcome'.freeze
    end

    def self.send_only_once?
      true
    end

    def sms_body(**args)
      if Flipper.enabled?(:immediate_df_closure)
        I18n.t("messages.state_file.welcome.immediate_df_closure_sms", **args)
      else
        I18n.t("messages.state_file.welcome.sms", **args)
      end
    end

    def email_subject(**args)
      if Flipper.enabled?(:immediate_df_closure)
        I18n.t("messages.state_file.welcome.email.immediate_df_closure_subject", **args)
      else
        I18n.t("messages.state_file.welcome.email.subject", **args)
      end
    end

    def email_body(**args)

      I18n.t("messages.state_file.welcome.email.body", **args)
    end
  end
end
