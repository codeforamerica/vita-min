module StateFile
  module Questions
    class NjEligibilityHealthInsuranceController < QuestionsController
      include EligibilityOffboardingConcern
    end
  end
end