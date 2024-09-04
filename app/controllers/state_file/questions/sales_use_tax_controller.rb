module StateFile
  module Questions
    class SalesUseTaxController < QuestionsController
      include ReturnToReviewConcern
    end
  end
end
