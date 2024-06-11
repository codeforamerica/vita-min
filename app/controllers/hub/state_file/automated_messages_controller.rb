module Hub::StateFile
  class AutomatedMessagesController < Hub::StateFile::BaseController
    helper_method :render_message

    def index
      Rails.application.eager_load!
      @messages = StateFile::AutomatedMessage::BaseAutomatedMessage.descendants
      @locales = [:en, :es]
    end

    private

    def render_message(klass, locale)
      replaced_body = klass.new.email_body(locale: locale).gsub('<<', '&lt;&lt;').gsub('>>', '&gt;&gt;')
      email = StateFileNotificationEmail.new(to: "example@example.com",
                                             body: replaced_body,
                                             subject: klass.new.email_subject)
      message = StateFile::NotificationMailer.user_message(notification_email: email)
      ActionMailer::Base.preview_interceptors.each do |interceptor|
        interceptor.previewing_email(message)
      end
      message
    end
  end
end