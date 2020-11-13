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
  end
end
