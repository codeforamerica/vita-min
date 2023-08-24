module Questions
  class FeedbackController < PostCompletionQuestionsController
    include AuthenticatedClientConcern

    layout "intake"

    def illustration_path; end
  end
end
