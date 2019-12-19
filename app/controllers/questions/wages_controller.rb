module Questions
  class WagesController < QuestionsController
    skip_before_action :ensure_intake_present

    def update_session
      session[:intake_id] = @form.intake.id
    end
  end
end