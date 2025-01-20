module StateFile
  module Questions
    class NjEstimatedTaxPaymentsController < QuestionsController
      include ReturnToReviewConcern
    end
  end
end
