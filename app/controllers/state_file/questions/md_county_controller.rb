module StateFile
  module Questions
    class MdCountyController < QuestionsController
      include ReturnToReviewConcern
      def edit
        @filing_year = Rails.configuration.statefile_current_tax_year
        @counties = current_intake.counties_for_select
        @subdivisions = current_intake.subdivisions_for_select
        super
      end
    end
  end
end