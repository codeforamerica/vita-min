module StateFile
  module Questions
    class AzPrimaryStateIdController < QuestionsController
      include ReturnToReviewConcern
    end
  end
end
