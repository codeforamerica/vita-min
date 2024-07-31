module StateFile
  module Questions
    class NyPrimaryStateIdController < QuestionsController
      include ReturnToReviewConcern
    end
  end
end
