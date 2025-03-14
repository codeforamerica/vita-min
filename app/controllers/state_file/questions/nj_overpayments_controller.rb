module StateFile
  module Questions
    class NjOverpaymentsController < QuestionsController
      include ReturnToReviewConcern
    end
  end
end
