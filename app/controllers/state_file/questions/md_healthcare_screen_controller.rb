module StateFile
  module Questions
    class MdHealthcareScreenController < QuestionsController
      include ReturnToReviewConcern
    end
  end
end
