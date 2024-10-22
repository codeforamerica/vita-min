module StateFile
  module Questions
    class IdGroceryCreditReviewController < QuestionsController
      include ReturnToReviewConcern
    end
  end
end
