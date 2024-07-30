module StateFile
  class AfterTransitionMessagingService
    include Rails.application.routes.url_helpers

    def initialize(efile_submission)
      @intake = efile_submission.data_source
      @submission = efile_submission
      raise(ArgumentError, "Unsupported intake type: #{@intake.class.name}") unless StateFile::StateInformationService.state_intake_classes.include?(@intake.class)
    end

    def send_efile_submission_accepted_message
      case @intake.refund_or_owe_taxes_type
      when :refund, :none
        message = StateFile::AutomatedMessage::AcceptedRefund
        body_args = { return_status_link: return_status_link }
      when :owe
        message = StateFile::AutomatedMessage::AcceptedOwe
        body_args = {
          state_pay_taxes_link: StateFile::StateInformationService.pay_taxes_link(@intake.state_code),
          return_status_link: return_status_link
        }
      end

      StateFile::MessagingService.new(
        intake: @intake,
        submission: @submission,
        message: message,
        body_args: body_args).send_message(require_verification: false)

      schedule_survey_notification_job
    end

    def schedule_survey_notification_job
      SendSurveyNotificationJob.set(
        wait_until: 23.hours.from_now
      ).perform_later(@intake, @submission)
    end

    def send_efile_submission_rejected_message
      message = StateFile::AutomatedMessage::Rejected
      body_args = { return_status_link: return_status_link }
      StateFile::MessagingService.new(
        intake: @intake,
        submission: @submission,
        message: message,
        body_args: body_args
      ).send_message(require_verification: false)
    end

    def send_efile_submission_still_processing_message
      message = StateFile::AutomatedMessage::StillProcessing
      StateFile::MessagingService.new(
        intake: @intake,
        submission: @submission,
        message: message
      ).send_message
    end

    def send_efile_submission_successful_submission_message
      message = StateFile::AutomatedMessage::SuccessfulSubmission
      submitted_key = @intake.efile_submissions.count > 1 ? "resubmitted" : "submitted"
      submitted_or_resubmitted = I18n.t("messages.state_file.successful_submission.email.#{submitted_key}", locale: (@intake.locale || "en"))
      body_args = { return_status_link: return_status_link, submitted_or_resubmitted: submitted_or_resubmitted }

      StateFile::MessagingService.new(
        intake: @intake,
        submission: @submission,
        message: message,
        body_args: body_args
      ).send_message
    end

    private

    def return_status_link
      url_for(
        host: MultiTenantService.new(:statefile).host,
        controller: "state_file/questions/return_status",
        action: "edit"
      )
    end
  end
end