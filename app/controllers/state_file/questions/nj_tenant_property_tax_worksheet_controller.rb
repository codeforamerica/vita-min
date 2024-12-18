module StateFile
  module Questions
    class NjTenantPropertyTaxWorksheetController < QuestionsController
      include ReturnToReviewConcern

      def self.show?(intake)
        intake.household_rent_own_rent? &&
          StateFile::NjTenantEligibilityHelper.determine_eligibility(intake) == StateFile::NjTenantEligibilityHelper::WORKSHEET &&
          Efile::Nj::NjPropertyTaxEligibility.possibly_eligible_for_deduction_or_credit?(intake)
      end
    end
  end
end