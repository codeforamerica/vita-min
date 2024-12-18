module StateFile
  module Questions
    class NcSubtractionsController < QuestionsController
      include ReturnToReviewConcern
      before_action :set_ivars, only: [:edit, :update]

      def set_ivars
        @subtractions_limit = current_intake.calculator.subtractions_limit
      end
    end
  end
end
