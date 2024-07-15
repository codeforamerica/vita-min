module StateFile
  module Questions
    class NyEligibilityOutOfStateIncomeController < AuthenticatedQuestionsController
      include EligibilityOffboardingConcern
    end
  end
end