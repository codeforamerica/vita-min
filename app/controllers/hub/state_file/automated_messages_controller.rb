module Hub::StateFile
  class AutomatedMessagesController < Hub::StateFile::BaseController
    include StateFile::SurveyLinksConcern
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
      intake = @intake || StateFileAzIntake.new(
        locale: "en",
        primary_first_name: "Cornelius"
      )
      state_code = intake.state_code
      locale = intake.locale || "en"
      submitted_key = intake.efile_submissions.count > 1 ? "resubmitted" : "submitted"
      {
        primary_first_name: intake.primary_first_name,
        intake_id: intake.id,
        survey_link: survey_link(intake),
        submitted_or_resubmitted: I18n.t("messages.state_file.successful_submission.email.#{submitted_key}", locale: locale),
        state_name: intake.state_name,
        return_status_link: SendRejectResolutionReminderNotificationJob.return_status_link(state_code, locale),
        login_link: SendIssueResolvedMessageJob.login_link,
        state_pay_taxes_link: StateFile::AfterTransitionMessagingService.state_pay_taxes_link(state_code),
      }
    end

    def email_message(message_class, locale)
      replaced_body = message_class.new.email_body(
        **{locale: locale}.update(message_params)
      ).gsub('<<', '&lt;&lt;').gsub('>>', '&gt;&gt;')
      subject = message_class.new.email_subject(
        **{locale: locale}.update(message_params)
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
        **{locale: locale}.update(message_params)
      )
    end
  end
end