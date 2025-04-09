module StateFile::AutomatedMessage
  class AcceptedOwe < BaseAutomatedMessage
    def self.name
      'messages.state_file.accepted_owe'.freeze
    end

    def self.after_transition_notification?
      true
    end

    def self.send_only_once?
      true
    end

    def sms_body(**args)
      time = app_time(args)

      if time.between? tax_deadline.beginning_of_day, tax_deadline
        I18n.t('messages.state_file.accepted_owe.during_deadline.sms', **args)
      elsif time > tax_deadline
        I18n.t('messages.state_file.accepted_owe.after_deadline.sms', **args)
      else
        I18n.t('messages.state_file.accepted_owe.before_deadline.sms', **args)
      end
    end

    def email_subject(**args)
      time = app_time(args)

      if time.between? tax_deadline.beginning_of_day, tax_deadline
        I18n.t('messages.state_file.accepted_owe.during_deadline.email.subject', **args)
      elsif time > tax_deadline
        I18n.t('messages.state_file.accepted_owe.after_deadline.email.subject', **args)
      else
        I18n.t('messages.state_file.accepted_owe.before_deadline.email.subject', **args)
      end
    end

    def email_body(**args)
      time = app_time(args)

      if time.between? tax_deadline.beginning_of_day, tax_deadline
        I18n.t('messages.state_file.accepted_owe.during_deadline.email.body', **args)
      elsif time > tax_deadline
        I18n.t('messages.state_file.accepted_owe.after_deadline.email.body', **args)
      else
        I18n.t('messages.state_file.accepted_owe.before_deadline.email.body', **args)
      end
    end
  end
end
