module Questions
  class WelcomeController < QuestionsController
    include AnonymousIntakeConcern

    skip_before_action :require_intake
    layout "application"

    private

    def illustration_path; end
  end
end
