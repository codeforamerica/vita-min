module Questions
  class AdditionalInfoController < QuestionsController
    layout "question"

    def section_title
      "Additional Questions"
    end

    def after_update_success
      SendIntakePdfToZendeskJob.perform_later(current_intake.id)
    end
  end
end