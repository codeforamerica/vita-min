module StateFile
  module Questions
    class NcPrimaryStateIdController < QuestionsController
      include ReturnToReviewConcern
    end
  end
end
