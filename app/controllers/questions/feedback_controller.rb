module Questions
  class FeedbackController < QuestionsController
    layout "intake"

    def current_intake
      intake_from_completed_session
    end

    def illustration_path; end

    def next_path
      root_path
    end
  end
end