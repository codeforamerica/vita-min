module Questions
  class SuccessfullySubmittedController < PostCompletionQuestionsController
    include AuthenticatedClientConcern

    def include_analytics?
      true
    end
  end
end
