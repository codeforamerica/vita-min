module StateFile
  module Questions
    class AzEligibilityOutOfStateIncomeController < AuthenticatedQuestionsController
      include EligibilityOffboardingConcern
    end
  end
end