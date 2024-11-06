module StateFile
  module Questions
    class NjHomeownerPropertyTaxController < QuestionsController
      include ReturnToReviewConcern

      before_action -> { @filing_year = Rails.configuration.statefile_current_tax_year }
      before_action -> { @municipality = current_intake.municipality_name }

      def self.show?(intake)
        intake.household_rent_own_own? &&
        StateFile::NjHomeownerEligibilityHelper.determine_eligibility(intake) == StateFile::NjHomeownerEligibilityHelper::ADVANCE &&
        Efile::Nj::NjPropertyTaxEligibility.determine_eligibility(intake) == Efile::Nj::NjPropertyTaxEligibility::POSSIBLY_ELIGIBLE_FOR_DEDUCTION_OR_CREDIT
      end
    end
  end
end