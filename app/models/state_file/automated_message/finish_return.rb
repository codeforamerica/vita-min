module StateFile::AutomatedMessage
  class FinishReturn < BaseAutomatedMessage

    def self.name
      'messages.state_file.finish_return'.freeze
    end

    def self.send_only_once?
      true
    end

    def sms_body(**args)
      time = app_time(args)

      if time.between?(tax_deadline.beginning_of_day, tax_deadline)
        I18n.t("messages.state_file.finish_return.sms.on_april_15", **args)
      else
        I18n.t("messages.state_file.finish_return.sms.pre_deadline", **args)
      end
    end

    def email_subject(**args)
      I18n.t("messages.state_file.finish_return.email.subject", **args)
    end

    def email_body(**args)
      time = app_time(args)

      if time.between?(tax_deadline.beginning_of_day, tax_deadline)
        I18n.t("messages.state_file.finish_return.email.body.on_april_15", **args)
      else
        I18n.t("messages.state_file.finish_return.email.body.pre_deadline", **args)
      end
    end
  end
end
