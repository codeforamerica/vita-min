module Questions
  class AdditionalInfoController < QuestionsController
    layout "question"

    def section_title
      "Additional Questions"
    end

    def after_update_success
      SendIntakePdfToZendeskJob.perform_later(current_intake.id)
    end

    def next_path
      next_step = DocumentNavigation.new(self).first_for_intake(current_intake)
      document_path(next_step.to_param)
    end
  end
end