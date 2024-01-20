module StateFile
  module Questions
    class NycResidencyController < AuthenticatedQuestionsController
      # the order of these two concerns is important.
      # they both overwrite next_path and defer to super.
      # offboarding should be last because its next_path method should take precedence and should be called first.
      # returning to review should be first because we should only return to review if the answer is not disqualifying
      include ReturnToReviewConcern
      include EligibilityOffboardingConcern
    end
  end
end
