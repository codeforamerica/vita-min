module Questions
  class SpouseConsentController < QuestionsController
    skip_before_action :require_sign_in
    layout "application"

    def self.show?(intake)
      intake.filing_joint_yes?
    end

    private

    def after_update_success
      if session[:authenticate_spouse_only]
        SendSpouseAuthDocsToZendeskJob.perform_later(current_intake.id)
      end
    end

    def next_path
      if session[:authenticate_spouse_only]
        verify_spouse_done_path
      else
        super
      end
    end

    def form_params
      super.merge(
        spouse_consented_to_service_ip: request.remote_ip,
      )
    end
  end
end
