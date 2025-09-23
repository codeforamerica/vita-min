module StateFile::AutomatedMessage
  class Rejected < BaseAutomatedMessage

    def self.name
      'messages.state_file.rejected'.freeze
    end

    def self.after_transition_notification?
      true
    end

    def self.send_only_once?
      true
    end

    def sms_body(**args)
      time = app_time(args)
      if time >= end_of_login.beginning_of_day
        I18n.t("messages.state_file.rejected.sms_with_deadline", **args)
      else
        I18n.t("messages.state_file.rejected.sms", **args)
      end
    end

    def email_subject(**args)
      I18n.t("messages.state_file.rejected.email.subject", **args)
    end

    def email_body(**args)
      time = app_time(args)
      if time >= end_of_login.beginning_of_day
        I18n.t("messages.state_file.rejected.email.body_with_deadline", **args)
      else
        I18n.t("messages.state_file.rejected.email.body", **args)
      end
    end
  end
end