module Hub::StateFile
  class AutomatedMessagesController < Hub::StateFile::BaseController

    def index
      @messages = messages_preview
    end

    private

    def messages_preview
      Rails.application.eager_load!
      message_classes = StateFile::AutomatedMessage::BaseAutomatedMessage.descendants
      message_classes.to_h do |klass|
        replaced_body = klass.new.email_body.gsub('<<', '&lt;&lt;').gsub('>>', '&gt;&gt;')
        email = StateFileNotificationEmail.new(to: "example@example.com",
                                               body: replaced_body,
                                               subject: klass.new.email_subject)
        message = StateFile::NotificationMailer.user_message(notification_email: email)
        ActionMailer::Base.preview_interceptors.each do |interceptor|
          interceptor.previewing_email(message)
        end
        [klass, message]
      end
    end
  end
end