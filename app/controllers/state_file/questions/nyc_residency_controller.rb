module StateFile
  module Questions
    class NycResidencyController < QuestionsController
      # the order of these two concerns is important.
      # they both overwrite next_path and defer to super.
      # offboarding should be last because its next_path method should take precedence and should be called first.
      # returning to review should be first because we should only return to review if the answer is not disqualifying
      include ReturnToReviewConcern
      include EligibilityOffboardingConcern

      def update
        update_for_device_id_collection(current_intake&.initial_efile_device_info)
      end
    end
  end
end
