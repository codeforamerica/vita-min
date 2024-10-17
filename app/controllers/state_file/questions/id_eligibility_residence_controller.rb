module StateFile
  module Questions
    class IdEligibilityResidenceController < QuestionsController
      include EligibilityOffboardingConcern
    end
  end
end