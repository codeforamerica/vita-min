module Questions
  class SpouseConsentController < QuestionsController
    include AuthenticatedClientConcern

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
      GenerateRequiredConsentPdfJob.perform_later(current_intake, "Consent Form 14446.pdf")
      GenerateF13614cPdfJob.perform_later(current_intake.id, "Preliminary 13614-C.pdf")
    end
  end
end
