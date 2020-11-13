module Questions
  class FinalInfoController < QuestionsController
    layout "question"

    def illustration_path; end

    def after_update_success
      current_intake.update(completed_at: Time.now)
    end

    def tracking_data
      {}
    end
  end
end
