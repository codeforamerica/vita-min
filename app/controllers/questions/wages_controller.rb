module Questions
  class WagesController < QuestionsController
    skip_before_action :ensure_intake_present
    layout "yes_no_question"

    def update_session
      session[:intake_id] = @form.intake.id
    end

    def section_title
      "Income"
    end
  end
end