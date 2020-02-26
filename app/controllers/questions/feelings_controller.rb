module Questions
  class FeelingsController < QuestionsController
    skip_before_action :require_sign_in
    layout "question"

    def current_intake
      @intake
    end

    def edit
      @intake = Intake.new
      super
    end

    def update
      @intake = Intake.create(source: source, referrer: referrer)
      session[:intake_id] = @intake.id
      super
    end

    def illustration_path; end
  end
end