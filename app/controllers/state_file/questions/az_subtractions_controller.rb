module StateFile
  module Questions
    class AzSubtractionsController < QuestionsController
      include ReturnToReviewConcern
      def self.show?(intake)
        wages_salaries_tips = intake.direct_file_data.fed_wages_salaries_tips
        wages_salaries_tips.present? && wages_salaries_tips > 0
      end

      private

      def form_params
        params.require(:state_file_az_subtractions_form).permit(
          [:armed_forces_member, :armed_forces_wages, :tribal_member, :tribal_wages]
        )
      end
    end
  end
end
