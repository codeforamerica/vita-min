module Questions
  class AdditionalInfoController < QuestionsController
    layout "question"

    def after_update_success
      SendIntakePdfToZendeskJob.perform_later(current_intake.id)
    end

    def next_path
      next_step = DocumentNavigation.first_for_intake(current_intake)
      document_path(next_step.to_param)
    end

    def tracking_data
      {}
    end
  end
end
