module StateFile
  class AfterTransitionMessagingService
    include Rails.application.routes.url_helpers

    def initialize(efile_submission)
      @intake = efile_submission.data_source
      @submission = efile_submission
      raise(ArgumentError, "Unsupported intake type: #{@intake.class.name}") unless %w[StateFileAzIntake StateFileNyIntake].include?(@intake.class.name)
    end

    def send_efile_submission_accepted_message
      case @intake.refund_or_owe_taxes_type
      when :refund, :none
        message = StateFile::AutomatedMessage::AcceptedRefund
        body_args = { return_status_link: return_status_link }
      when :owe
        message = StateFile::AutomatedMessage::AcceptedOwe
        body_args = { state_pay_taxes_link: state_pay_taxes_link, return_status_link: return_status_link }
      end

      StateFile::MessagingService.new(
        intake: @intake,
        submission: @submission,
        message: message,
        body_args: body_args).send_message

      schedule_survey_notification_job
    end

    def schedule_survey_notification_job
      SendSurveyNotificationJob.set(
        wait_until: 23.hours.from_now
      ).perform_later(
        intake: @intake,
        submission: @submission
      )
    end

    def send_efile_submission_rejected_message
      message = StateFile::AutomatedMessage::Rejected
      body_args = { return_status_link: return_status_link }
      StateFile::MessagingService.new(
        intake: @intake,
        submission: @submission,
        message: message,
        body_args: body_args).send_message
    end

    private

    def return_status_link
      url_for(host: MultiTenantService.new(:statefile).host, controller: "state_file/questions/return_status", action: "edit", us_state: @intake.state_code)
    end

    def state_pay_taxes_link
      case @intake.state_code
      when "ny"
        "https://www.tax.ny.gov/pay/"
      when 'az'
        "https://www.aztaxes.gov/"
      else
        ""
      end
    end
  end
end