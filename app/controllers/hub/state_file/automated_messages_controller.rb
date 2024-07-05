module Hub::StateFile
  class AutomatedMessagesController < Hub::StateFile::BaseController
    helper_method :email_message
    helper_method :sms_body

    def index
      Rails.application.eager_load!
      @messages = StateFile::AutomatedMessage::BaseAutomatedMessage.descendants
      @locales = [:en, :es]
      get_intake
    end

    def send_notification

      Rails.application.eager_load!
      message = params[:message]
      message_classes = StateFile::AutomatedMessage::BaseAutomatedMessage.descendants
      message_class = message_classes.find { |c| c.name == message }
      StateFile::MessagingService.new(
        intake: get_intake,
        submission: get_intake.efile_submissions.last,
        message: message_class,
        body_args: message_params
      ).send_message(require_verification: false)

      respond_to do |format|
        format.js
      end
    end

    private

    def get_state_code
      active_state_codes = StateFile::StateInformationService.active_state_codes
      intake = params[:intake]
      if intake.present?
        state_code = intake[0..1].downcase
        return state_code if active_state_codes.include?(state_code)
      end
      active_state_codes.first
    end

    def get_intake
      return @intake if @intake.present?
      active_state_codes = StateFile::StateInformationService.active_state_codes
      intake = params[:intake]
      if intake.present?
        state_code = intake[0..1].downcase
        intake_id = intake[2..].to_i
        unless active_state_codes.include?(state_code)
          state_code = active_state_codes.first
          intake_id = intake
        end
        intake_class = StateFile::StateInformationService.intake_class(state_code)
        @intake = intake_class.find_by_id(intake_id)
        return @intake if @intake.present?
        flash.now.alert = "Unknown Intake"
      end
      intake_class = StateFile::StateInformationService.intake_class(active_state_codes.first)
      @intake = intake_class.new(
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