module StateFile
  module Questions
    class AzPrimaryStateIdController < AuthenticatedQuestionsController
      include ReturnToReviewConcern
    end
  end
end
