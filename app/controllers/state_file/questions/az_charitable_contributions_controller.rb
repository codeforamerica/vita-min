module StateFile
  module Questions
    class AzCharitableContributionsController < QuestionsController
      private

      def form_params
        params.require(:state_file_az_charitable_contributions_form).permit([:charitable_contributions, :charitable_cash, :charitable_noncash])
      end
    end
  end
end
