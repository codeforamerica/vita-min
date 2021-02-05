module Questions
  class WelcomeController < QuestionsController
    skip_before_action :require_intake
    layout "application"

    def edit; end

    private

    def illustration_path; end
  end
end
