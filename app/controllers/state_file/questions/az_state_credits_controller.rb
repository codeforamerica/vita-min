module StateFile
  module Questions
    class AzStateCreditsController < QuestionsController
      private

      def form_params
        params.require(:state_file_az_state_credits_form).permit([:prior_last_names, :has_prior_last_names])
      end
    end
  end
end
