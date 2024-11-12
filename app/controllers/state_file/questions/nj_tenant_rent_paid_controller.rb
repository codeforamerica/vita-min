module StateFile
  module Questions
    class NjTenantRentPaidController < QuestionsController
      include ReturnToReviewConcern

      before_action -> { @filing_year = Rails.configuration.statefile_current_tax_year }

      def self.show?(intake)
        intake.household_rent_own_rent? &&
        StateFile::NjTenantEligibilityHelper.determine_eligibility(intake) == StateFile::NjTenantEligibilityHelper::ADVANCE &&
        Efile::Nj::NjPropertyTaxEligibility.possibly_eligible_for_deduction_or_credit?(intake)
      end
    end
  end
end
