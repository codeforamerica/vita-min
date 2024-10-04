module StateFile
  module Questions
    class NjHomeownerPropertyTaxController < QuestionsController
      include ReturnToReviewConcern

      before_action -> { @filing_year = Rails.configuration.statefile_current_tax_year }
      before_action -> { @municipality = current_intake.municipality_name }

      def self.show?(intake)
        intake.household_rent_own == 'own' && StateFile::NjHomeownerEligibilityHelper.determine_eligibility(intake) == 'advance'
      end
    end
  end
end