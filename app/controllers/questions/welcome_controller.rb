module Questions
  class WelcomeController < QuestionsController
    include AnonymousIntakeConcern

    skip_before_action :require_intake
    layout "application"

    def edit
      redirect_to root_path unless open_for_intake?
    end

    private

    def illustration_path; end
  end
end
