module StateFile
  class AfterTransitionMessagingService
    include Rails.application.routes.url_helpers

    def initialize(intake)
      @intake = intake
      raise(ArgumentError, "Unsupported intake type: #{intake.class.name}") unless %w[StateFileAzIntake StateFileNyIntake].include?(intake.class.name)
    end

    def send_efile_submission_accepted_message
      if @intake.calculated_refund_or_owed_amount.positive?
        message = StateFile::AutomatedMessage::AcceptedRefund
        body_args = { return_status_link: return_status_link }
      else
        message = StateFile::AutomatedMessage::AcceptedOwe
        body_args = { state_pay_taxes_link: state_pay_taxes_link, return_status_link: return_status_link }
      end

      StateFile::MessagingService.new(
        intake: @intake,
        message: message,
        body_args: body_args).send_message
    end

    def send_efile_submission_rejected_message
      message = StateFile::AutomatedMessage::Rejected
      body_args = { return_status_link: return_status_link }
      StateFile::MessagingService.new(
        intake: @intake,
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