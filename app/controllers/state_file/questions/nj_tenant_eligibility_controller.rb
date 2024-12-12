module StateFile
  module Questions
    class NjTenantEligibilityController < QuestionsController
      include ReturnToReviewConcern

      def self.show?(intake)
        (intake.household_rent_own_rent? || intake.household_rent_own_both?) &&
          !Efile::Nj::NjPropertyTaxEligibility.ineligible?(intake)
      end

      def next_path
        options = {}
        options[:return_to_review] = params[:return_to_review] if params[:return_to_review].present?
        
        if StateFile::NjTenantEligibilityHelper.determine_eligibility(current_intake) == StateFile::NjTenantEligibilityHelper::INELIGIBLE
          NjIneligiblePropertyTaxController.to_path_helper(options)
        elsif Efile::Nj::NjPropertyTaxEligibility.possibly_eligible_for_credit?(current_intake)
          super # skip "rent paid" question and go to whichever is next by default
        elsif StateFile::NjTenantEligibilityHelper.determine_eligibility(current_intake) == StateFile::NjTenantEligibilityHelper::WORKSHEET
          NjTenantPropertyTaxWorksheetController.to_path_helper(options)
        else
          NjTenantRentPaidController.to_path_helper(options)
        end
      end
    end
  end
end