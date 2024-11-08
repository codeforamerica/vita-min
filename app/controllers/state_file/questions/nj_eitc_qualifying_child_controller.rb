module StateFile
  module Questions
    class NjEitcQualifyingChildController < QuestionsController
      include ReturnToReviewConcern

      before_action -> { @filing_year = Rails.configuration.statefile_current_tax_year }

      def self.show?(intake)
        Efile::Nj::NjFlatEitcEligibility.possibly_eligible?(intake)
      end
    end
  end
end
