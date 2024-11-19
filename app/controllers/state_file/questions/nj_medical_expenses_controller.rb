module StateFile
  module Questions
    class NjMedicalExpensesController < QuestionsController
      include ReturnToReviewConcern
    end
  end
end
