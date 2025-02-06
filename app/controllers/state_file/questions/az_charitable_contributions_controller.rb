module StateFile
  module Questions
    class AzCharitableContributionsController < QuestionsController
      include ReturnToReviewConcern
    end
  end
end
