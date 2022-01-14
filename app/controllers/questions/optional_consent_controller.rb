module Questions
  class OptionalConsentController < QuestionsController
    layout "intake"

    def illustration_path; end

    def form_params
      super.merge(
        ip: request.remote_ip,
        user_agent: request.user_agent
      )
    end

    def after_update_success
      GenerateOptionalConsentPdfJob.perform_later(current_intake.client.consent)
    end
  end
end
