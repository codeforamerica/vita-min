module Questions
  class ConsentController < QuestionsController
    skip_before_action :require_sign_in
    layout "application"

    def form_params
      super.merge(
        primary_consented_to_service_ip: request.remote_ip,
      )
    end
  end
end
