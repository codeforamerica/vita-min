module StateFile
  module Questions
    class AzCharitableContributionsController < AuthenticatedQuestionsController
      include ReturnToReviewConcern
      include StateSpecificQuestionConcern

      private
    end
  end
end
