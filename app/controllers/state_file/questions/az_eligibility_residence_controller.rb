module StateFile
  module Questions
    class AzEligibilityResidenceController < QuestionsController
      include EligibilityOffboardingConcern
    end
  end
end