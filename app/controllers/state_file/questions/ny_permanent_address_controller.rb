module StateFile
  module Questions
    class NyPermanentAddressController < AuthenticatedQuestionsController
      include EligibilityOffboardingConcern
    end
  end
end
