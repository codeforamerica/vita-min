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

      i18n_msg = if time.between? tax_deadline.beginning_of_day, tax_deadline
                   'messages.state_file.accepted_owe.during_deadline.sms'
                 elsif time > tax_deadline
                   'messages.state_file.accepted_owe.after_deadline.sms'
                 else
                   'messages.state_file.accepted_owe.before_deadline.sms'
                 end

      I18n.t(i18n_msg, **args)
    end

    def email_subject(**args)
      time = app_time(args)

      i18n_msg = if time.between? tax_deadline.beginning_of_day, tax_deadline
                   'messages.state_file.accepted_owe.during_deadline.email.subject'
                 elsif time > tax_deadline
                   'messages.state_file.accepted_owe.after_deadline.email.subject'
                 else
                   'messages.state_file.accepted_owe.before_deadline.email.subject'
                 end

      I18n.t(i18n_msg, **args)
    end

    def email_body(**args)
      time = app_time(args)

      i18n_msg = if time.between? tax_deadline.beginning_of_day, tax_deadline
                   'messages.state_file.accepted_owe.during_deadline.email.body'
                 elsif time > tax_deadline
                   'messages.state_file.accepted_owe.after_deadline.email.body'
                 else
                   'messages.state_file.accepted_owe.before_deadline.email.body'
                 end

      I18n.t(i18n_msg, **args)
    end
  end
end
