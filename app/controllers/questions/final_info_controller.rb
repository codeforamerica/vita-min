module Questions
  class FinalInfoController < QuestionsController
    layout "question"

    def illustration_path; end

    def after_update_success
      SendCompletedIntakeToZendeskJob.perform_later(current_intake.id)
    end

    def tracking_data
      {}
    end
  end
end