module Questions
  class ConsentController < QuestionsController
    layout "application"

    def form_params
      super.merge(
        primary_consented_to_service_ip: request.remote_ip,
      )
    end

    def after_update_success
      current_intake.advance_tax_return_statuses_to("intake_in_progress")
    end
  end
end
