module Questions
  class AdditionalInfoController < QuestionsController
    layout "question"

    def tracking_data
      {}
    end

    def after_update_success
      current_intake.update(completed_yes_no_questions_at: DateTime.current) if current_intake.completed_yes_no_questions_at.nil?
      IntakePdfJob.perform_later(current_intake.id, "Preliminary 13614-C with 15080.pdf")
    end
  end
end
