module StateFile
  module Questions
    class MdPermanentAddressController < QuestionsController
      include ReturnToReviewConcern
      include EligibilityOffboardingConcern
    end
  end
end
