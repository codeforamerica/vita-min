module StateFile
  module Questions
    class NyEligibilityResidenceController < AuthenticatedQuestionsController
      include EligibilityOffboardingConcern
    end
  end
end