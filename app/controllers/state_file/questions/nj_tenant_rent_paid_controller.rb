module StateFile
  module Questions
    class NjTenantRentPaidController < QuestionsController
      include ReturnToReviewConcern

      before_action -> { @filing_year = Rails.configuration.statefile_current_tax_year }

      def self.show?(intake)
        intake.household_rent_own == 'rent'
      end
    end
  end
end
