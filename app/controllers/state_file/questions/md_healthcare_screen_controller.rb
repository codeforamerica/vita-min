module StateFile
  module Questions
    class MdHealthcareScreenController < QuestionsController
      binding.pry
      include ReturnToReviewConcern
    end
  end
end
