module StateFile
  module Questions
    class PrimaryStateIdController < QuestionsController
      include ReturnToReviewConcern
    end
  end
end
