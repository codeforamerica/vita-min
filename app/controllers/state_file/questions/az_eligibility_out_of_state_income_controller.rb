module StateFile
  module Questions
    class AzEligibilityOutOfStateIncomeController < QuestionsController
      include EligibilityOffboardingConcern
    end
  end
end