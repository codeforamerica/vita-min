module Questions
  class SuccessfullySubmittedController < PostCompletionQuestionsController
    include AuthenticatedClientConcern, GyrDocuments

    before_action do
      next_state = has_all_required_docs?(current_intake) ? :intake_ready : :intake_needs_doc_help
      current_intake.tax_returns.each do |tax_return|
        tax_return.transition_to(next_state) if tax_return.current_state.to_sym != next_state
      end
    end

    def include_analytics?
      true
    end
  end
end
