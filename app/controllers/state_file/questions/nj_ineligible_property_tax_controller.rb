module StateFile
  module Questions
    class NjIneligiblePropertyTaxController < QuestionsController
      include ReturnToReviewConcern

      def next_path
        options = {}
        options[:return_to_review] = params[:return_to_review] if params[:return_to_review].present?

        if current_intake.household_rent_own_both? && StateFile::NjTenantEligibilityHelper.determine_eligibility(current_intake) != StateFile::NjTenantEligibilityHelper::INELIGIBLE
          NjTenantEligibilityController.to_path_helper(options)
        else
          StateFile::NjPropertyTaxFlowHelper.next_controller(options)
        end
      end
    end
  end
end

