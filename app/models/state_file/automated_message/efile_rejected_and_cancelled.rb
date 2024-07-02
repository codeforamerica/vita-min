module StateFile
  module AutomatedMessage
    class EfileRejectedAndCancelled < ::AutomatedMessage::AutomatedMessage

      def self.name
        'messages.efile.rejected_and_cancelled'.freeze
      end

      def sms_body(**args)
        I18n.t("messages.efile.rejected_and_cancelled.sms", **args)
      end

      def email_subject(**args)
        I18n.t("messages.efile.rejected_and_cancelled.email.subject", **args)
      end

      def email_body(**args)
        I18n.t("messages.efile.rejected_and_cancelled.email.body", **args)
      end
    end
  end
end
