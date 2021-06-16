module Questions
  class WelcomeController < QuestionsController
    include AnonymousIntakeConcern

    skip_before_action :require_intake
    layout "application"

    def edit
      redirect_to root_path if Rails.configuration.offseason
    end

    private

    def illustration_path; end
  end
end
