module StateFile
  module Questions
    class AzSubtractionsController < QuestionsController
      include ReturnToReviewConcern
      def self.show?(intake)
        current_intake.eligible_for_az_subtractions?
      end

      private

      def form_params
        params.require(:state_file_az_subtractions_form).permit(
          [:armed_forces_member, :armed_forces_wages_amount, :tribal_member, :tribal_wages_amount]
        )
      end
    end
  end
end
