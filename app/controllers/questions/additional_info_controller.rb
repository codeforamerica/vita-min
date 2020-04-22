module Questions
  class AdditionalInfoController < QuestionsController
    layout "question"

    def after_update_success
      SendIntakePdfToZendeskJob.perform_later(current_intake.id)
    end

    def tracking_data
      {}
    end
  end
end
