module StateFile
  module Questions
    class NyEligibilityCollegeSavingsWithdrawalController < AuthenticatedQuestionsController
      include EligibilityOffboardingConcern
    end
  end
end