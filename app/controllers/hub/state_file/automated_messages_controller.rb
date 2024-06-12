module Hub::StateFile
  class AutomatedMessagesController < Hub::StateFile::BaseController
    MESSAGE_PARAMS = {
      primary_first_name: "Cornelius",
      intake_id: 1234,
      survey_link: "/survey_link",
      submitted_or_resubmitted: true,
      state_name: "East Dakota",
      return_status_link: "/return_status",
      login_link: "/login",
      state_pay_taxes_link: "/pay_taxes",
    }.freeze
    helper_method :email_message
    helper_method :sms_body

    def index
      Rails.application.eager_load!
      @messages = StateFile::AutomatedMessage::BaseAutomatedMessage.descendants
      @locales = [:en, :es]
      @intake = GlobalID::Locator.locate params[:intake_gid]

    end

    private

    def message_params
      return MESSAGE_PARAMS unless @intake.present?

    end

    def email_message(message_class, locale)
      replaced_body = message_class.new.email_body(
        **{locale: locale}.update(MESSAGE_PARAMS)
      ).gsub('<<', '&lt;&lt;').gsub('>>', '&gt;&gt;')
      subject = message_class.new.email_subject(
        **{locale: locale}.update(MESSAGE_PARAMS)
      )
      email = StateFileNotificationEmail.new(to: "example@example.com",
                                             body: replaced_body,
                                             subject: subject)
      message = StateFile::NotificationMailer.user_message(notification_email: email)
      ActionMailer::Base.preview_interceptors.each do |interceptor|
        interceptor.previewing_email(message)
      end
      message
    end

    def sms_body(message_class, locale)
      message_class.new.sms_body(
        **{locale: locale}.update(MESSAGE_PARAMS)
      )
    end
  end
end