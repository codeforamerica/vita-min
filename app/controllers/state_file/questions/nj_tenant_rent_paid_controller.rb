module StateFile
  module Questions
    class NjTenantRentPaidController < QuestionsController
      include ReturnToReviewConcern

      def self.show?(intake)
        (intake.household_rent_own_rent? || intake.household_rent_own_both?) &&
        StateFile::NjTenantEligibilityHelper.determine_eligibility(intake) == StateFile::NjTenantEligibilityHelper::ADVANCE &&
        Efile::Nj::NjPropertyTaxEligibility.possibly_eligible_for_deduction_or_credit?(intake)
      end
    end
  end
end
