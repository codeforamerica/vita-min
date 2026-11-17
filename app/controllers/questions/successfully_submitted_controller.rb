module Questions
  class SuccessfullySubmittedController < PostCompletionQuestionsController
    include AuthenticatedClientConcern, GyrDocuments

    before_action do
      intake_transition_to(current_intake, next_intake_state(current_intake))
    end

    def include_analytics?
      true
    end
  end
end
