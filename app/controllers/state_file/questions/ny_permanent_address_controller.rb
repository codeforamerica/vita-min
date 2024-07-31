module StateFile
  module Questions
    class NyPermanentAddressController < QuestionsController
      include ReturnToReviewConcern
      include EligibilityOffboardingConcern
    end
  end
end
