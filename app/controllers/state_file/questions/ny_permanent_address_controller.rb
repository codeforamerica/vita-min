module StateFile
  module Questions
    class NyPermanentAddressController < AuthenticatedQuestionsController
      include ReturnToReviewConcern
      include EligibilityOffboardingConcern
    end
  end
end
