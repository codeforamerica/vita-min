module StateFile
  module Questions
    class NjHomeownerPropertyTaxWorksheetController < QuestionsController
      include ReturnToReviewConcern

      before_action -> { @municipality = current_intake.municipality_name }

      def self.show?(intake)
        intake.household_rent_own_own? &&
          StateFile::NjHomeownerEligibilityHelper.determine_eligibility(intake) == StateFile::NjHomeownerEligibilityHelper::WORKSHEET &&
          Efile::Nj::NjPropertyTaxEligibility.possibly_eligible_for_deduction_or_credit?(intake)
      end
    end
  end
end