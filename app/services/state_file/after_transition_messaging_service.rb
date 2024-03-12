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

      send_survey_notification_message
    end

    def send_survey_notification_message
      StateFile::MessagingService.new(
        intake: @intake,
        submission: @submission,
        message: StateFile::AutomatedMessage::SurveyNotification,
        body_args: { survey_link: survey_link }
      ).send_message
    end
    handle_asynchronously :send_survey_notification_message, :run_at => Proc.new { 24.hours.from_now }

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

    def survey_link
      case @intake.state_code
      when 'ny'
        'https://codeforamerica.co1.qualtrics.com/jfe/form/SV_3pXUfy2c3SScmgu'
      when 'az'
        'https://codeforamerica.co1.qualtrics.com/jfe/form/SV_7UTycCvS3UEokey'
      else
        ''
      end
    end
  end
end