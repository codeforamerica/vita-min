module StateFile
  module Questions
    class AzPriorLastNamesController < AuthenticatedQuestionsController
      include ReturnToReviewConcern

      private

      def form_params
        params.require(:state_file_az_prior_last_names_form).permit([:prior_last_names, :has_prior_last_names])
      end
    end
  end
end
