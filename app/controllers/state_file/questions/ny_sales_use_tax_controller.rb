module StateFile
  module Questions
    class NySalesUseTaxController < AuthenticatedQuestionsController
      include ReturnToReviewConcern

    end
  end
end
