module Questions
  class SuccessfullySubmittedController < PostCompletionQuestionsController
    include AuthenticatedClientConcern, GyrDocuments

    before_action do
      next_state = has_all_required_docs?(current_intake) ? :intake_ready : :intake_needs_doc_help
      advance_to(current_intake, next_state)
    end

    def include_analytics?
      true
    end
  end
end
