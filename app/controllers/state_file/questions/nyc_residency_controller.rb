module StateFile
  module Questions
    class NycResidencyController < AuthenticatedQuestionsController
      include EligibilityOffboardingConcern
    end
  end
end
