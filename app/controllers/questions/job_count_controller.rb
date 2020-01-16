module Questions
  class JobCountController < QuestionsController
    skip_before_action :ensure_intake_present
    layout "question"

    def update_session
      session[:intake_id] = @form.intake.id
    end

    def section_title
      "Income"
    end
  end
end