module StateFile
  module Questions
    class NcVeteranStatusController < QuestionsController
      include ReturnToReviewConcern
    end
  end
end
