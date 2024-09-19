module StateFile
  module Questions
    class NjHouseholdRentOwnController < QuestionsController
      include ReturnToReviewConcern

      def edit
        @filing_year = Rails.configuration.statefile_current_tax_year
        super
      end
    end
  end
end
