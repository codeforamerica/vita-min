module Hub::StateFile
  class AutomatedMessagesController < Hub::StateFile::BaseController
    helper_method :email_message
    helper_method :sms_body

    def index
      Rails.application.eager_load!
      @messages = StateFile::AutomatedMessage::BaseAutomatedMessage.descendants
      @locales = [:en, :es]
      @us_state = StateFile::StateInformationService.active_state_codes.include?(params[:us_state]) ? params[:us_state] : "az"
      get_intake
    end

    def send_notification
      puts "TRACE:send_notification"
      #redirect_to :index
      respond_to do |format|
        format.js
      end
    end

    private

    def get_intake
      return @intake if @intake.present?
      state_class = "StateFile#{@us_state.titleize}Intake".constantize
      if params[:intake_id].present?
        @intake = state_class.find_by_id(params[:intake_id])
        return @intake if @intake.present?
        flash.now.alert = "Unknown Intake"
      end
      @intake = state_class.new(
        locale: "en",
        primary_first_name: "Cornelius"
      )
    end

    def message_params
      intake = get_intake
      state_code = intake.state_code
      locale = intake.locale || "en"
      submitted_key = intake.efile_submissions.count > 1 ? "resubmitted" : "submitted"
      {
        primary_first_name: intake.primary_first_name,
        intake_id: intake.id || "CLIENT_ID",
        survey_link: StateFile::StateInformationService.survey_link(intake.state_code),
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