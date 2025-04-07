module StateFile::AutomatedMessage
  class FinishReturn < BaseAutomatedMessage

    def self.name
      'messages.state_file.finish_return'.freeze
    end

    def self.after_transition_notification?
      false
    end

    def self.send_only_once?
      true
    end

    def sms_body(**args)
      if app_time.between?(Rails.configuration.state_file_end_of_new_intakes.beginning_of_day, Rails.configuration.state_file_end_of_new_intakes)
        # during tax deadline day
        I18n.t("messages.state_file.finish_return.sms.on_april_15", **args)
      else
        I18n.t("messages.state_file.finish_return.sms.pre_deadline", **args)
      end
    end

    def email_subject(**args)
      I18n.t("messages.state_file.finish_return.email.subject", **args)
    end

    def email_body(**args)
      if app_time.between?(Rails.configuration.state_file_end_of_new_intakes.beginning_of_day, Rails.configuration.state_file_end_of_new_intakes)
        # during tax deadline day
        I18n.t("messages.state_file.finish_return.email.body.on_april_15", **args)
      else
        I18n.t("messages.state_file.finish_return.email.body.on_april_15", **args)
      end
    end
  end
end
