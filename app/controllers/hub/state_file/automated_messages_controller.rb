module Hub::StateFile
  class AutomatedMessagesController < Hub::StateFile::BaseController

    def index
      @messages = messages_preview
    end

    private

    def messages_preview
      automated_messages = [
        [StateFile::AutomatedMessage::Welcome, {}],
        [StateFile::AutomatedMessage::AcceptedRefund, {}],
        [StateFile::AutomatedMessage::AcceptedOwe, {}],
        [StateFile::AutomatedMessage::Rejected, {}],
        [StateFile::AutomatedMessage::IssueResolved, {}],
        [StateFile::AutomatedMessage::StillProcessing, {}],
        [StateFile::AutomatedMessage::SuccessfulSubmission, {}],
        [StateFile::AutomatedMessage::RejectResolutionReminder, {}],
      ]

      automated_messages_and_mailers = automated_messages.map do |m|
        message = m[0].new
        replaced_body = message.email_body.gsub('<<', '&lt;&lt;').gsub('>>', '&gt;&gt;')
        email = StateFileNotificationEmail.new(to: "example@example.com",
                                               body: replaced_body,
                                               subject: message.email_subject)
        [m[0], StateFile::NotificationMailer.user_message(notification_email: email)]
      end.to_h

      automated_messages_and_mailers.transform_values do |message|
        ActionMailer::Base.preview_interceptors.each do |interceptor|
          interceptor.previewing_email(message)
        end
        message
      end
    end
  end
end