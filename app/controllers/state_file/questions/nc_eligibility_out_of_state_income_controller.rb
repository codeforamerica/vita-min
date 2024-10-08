module StateFile
  module Questions
    class NcEligibilityOutOfStateIncomeController < QuestionsController
      include EligibilityOffboardingConcern
    end
  end
end