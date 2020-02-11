module Questions
  class ConsentController < QuestionsController
    layout "application"

    def form_params
      super.merge(
        consented_to_service_ip: request.remote_ip,
        consented_to_service_at: DateTime.current
      )
    end
  end
end
