module Questions
  class JobCountController < QuestionsController
    layout "question"

    def update_session
      session[:intake_id] = @form.intake.id
    end

    def section_title
      "Income and Expenses"
    end
  end
end