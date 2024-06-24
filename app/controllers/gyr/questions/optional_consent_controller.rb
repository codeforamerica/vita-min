module Questions
  class OptionalConsentController < QuestionsController
    include AuthenticatedClientConcern

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
      GenerateF13614cPdfJob.perform_later(current_intake.id, "Preliminary 13614-C.pdf")
    end
  end
end
