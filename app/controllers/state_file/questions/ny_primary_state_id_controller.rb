module StateFile
  module Questions
    class NyPrimaryStateIdController < AuthenticatedQuestionsController
      include ReturnToReviewConcern
    end
  end
end
