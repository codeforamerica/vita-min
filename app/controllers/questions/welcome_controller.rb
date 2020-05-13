module Questions
  class WelcomeController < QuestionsController
    layout "application"

    def current_intake
      super || Intake.new
    end

    def edit; end

    private

    def illustration_path; end
  end
end
