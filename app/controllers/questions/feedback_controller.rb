module Questions
  class FeedbackController < QuestionsController
    include AuthenticatedClientConcern
    layout "intake"

    def illustration_path; end
  end
end