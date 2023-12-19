module StateFile
  module Questions
    class NySalesUseTaxController < AuthenticatedQuestionsController
      include ReturnToReviewConcern
      include StateSpecificQuestionConcern

    end
  end
end
