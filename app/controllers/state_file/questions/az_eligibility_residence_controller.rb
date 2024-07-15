module StateFile
  module Questions
    class AzEligibilityResidenceController < AuthenticatedQuestionsController
      include EligibilityOffboardingConcern
    end
  end
end