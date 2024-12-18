module StateFile
  module Questions
    class MdCountyController < QuestionsController
      include ReturnToReviewConcern
      before_action :set_ivars, only: [:edit, :update]

      def set_ivars
        @counties = current_intake.counties_for_select
        @subdivisions_by_county = current_intake.counties_and_subdivisions_array
      end
    end
  end
end