module StateFile
  module Questions
    class NyEligibilityOutOfStateIncomeController < QuestionsController
      include EligibilityOffboardingConcern
    end
  end
end