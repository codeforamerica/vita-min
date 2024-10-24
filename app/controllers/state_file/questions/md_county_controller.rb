module StateFile
  module Questions
    class MdCountyController < QuestionsController
      include ReturnToReviewConcern
      before_action :set_ivars, only: [:edit, :update]

      def set_ivars
        @filing_year = Rails.configuration.statefile_current_tax_year
        @counties = current_intake.counties_for_select
        @subdivisions_by_county = current_intake.counties_and_subdivisions_array
      end
    end
  end
end