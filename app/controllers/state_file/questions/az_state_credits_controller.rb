module StateFile
  module Questions
    class AzStateCreditsController < AuthenticatedQuestionsController
      include ReturnToReviewConcern
      include StateSpecificQuestionConcern

      private

      def form_params
        params.require(:state_file_az_state_credits_form).permit(
          [:armed_forces_member, :armed_forces_wages, :tribal_member, :tribal_wages]
        )
      end
    end
  end
end
