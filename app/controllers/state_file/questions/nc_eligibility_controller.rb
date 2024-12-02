module StateFile
  module Questions
    class NcEligibilityController < QuestionsController
      include EligibilityOffboardingConcern
    end
  end
end
