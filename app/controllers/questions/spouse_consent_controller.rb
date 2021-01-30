module Questions
  class SpouseConsentController < QuestionsController
    layout "application"

    def self.show?(intake)
      intake.filing_joint_yes?
    end

    private

    def form_params
      super.merge(
        spouse_consented_to_service_ip: request.remote_ip,
      )
    end

    def after_update_success
      Intake14446PdfJob.perform_later(current_intake, "Consent Form.pdf")
      Intake13614CPdfJob.perform_later(current_intake, "Preliminary 13614-C.pdf")
    end
  end
end
