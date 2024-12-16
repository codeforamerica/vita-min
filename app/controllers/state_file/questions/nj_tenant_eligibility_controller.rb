module StateFile
  module Questions
    class NjTenantEligibilityController < QuestionsController
      include ReturnToReviewConcern

      def next_path
        options = {}
        options[:return_to_review] = params[:return_to_review] if params[:return_to_review].present?
        
        if StateFile::NjTenantEligibilityHelper.determine_eligibility(current_intake) == StateFile::NjTenantEligibilityHelper::INELIGIBLE
          NjIneligiblePropertyTaxController.to_path_helper(options)
        elsif Efile::Nj::NjPropertyTaxEligibility.possibly_eligible_for_credit?(current_intake)
          StateFile::NjPropertyTaxFlowHelper.next_controller(options)
        elsif StateFile::NjTenantEligibilityHelper.determine_eligibility(current_intake) == StateFile::NjTenantEligibilityHelper::WORKSHEET
          NjTenantPropertyTaxWorksheetController.to_path_helper(options)
        else
          NjTenantRentPaidController.to_path_helper(options)
        end
      end
    end
  end
end