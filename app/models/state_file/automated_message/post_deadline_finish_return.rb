module StateFile::AutomatedMessage
  class PostDeadlineFinishReturn < BaseAutomatedMessage

    def self.name
      'messages.state_file.finish_return'.freeze
    end

    def self.after_transition_notification?
      false
    end

    def self.send_only_once?
      false # we send this message once a month  April 16-October 15
    end

    def sms_body(**args)
      I18n.t("messages.state_file.post_deadline_finish_return.sms", **args)
    end

    def email_subject(**args)
      I18n.t("messages.state_file.post_deadline_finish_return.email.subject", **args)
    end

    def email_body(**args)
      I18n.t("messages.state_file.post_deadline_finish_return.email.body", **args)
    end
  end
end
