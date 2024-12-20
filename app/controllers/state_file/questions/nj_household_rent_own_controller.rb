module StateFile
  module Questions
    class NjHouseholdRentOwnController < QuestionsController
      include ReturnToReviewConcern

      def next_path
        options = {}
        options[:return_to_review] = params[:return_to_review] if params[:return_to_review].present?

        if Efile::Nj::NjPropertyTaxEligibility.ineligible?(current_intake)
          return StateFile::NjPropertyTaxFlowOffRamp.next_controller(options)
        end
        
        case current_intake.household_rent_own
        when 'rent'
          NjTenantEligibilityController.to_path_helper(options)
        when 'own', 'both'
          NjHomeownerEligibilityController.to_path_helper(options)
        when 'neither'
          NjIneligiblePropertyTaxController.to_path_helper(options)
        else
          StateFile::NjPropertyTaxFlowOffRamp.next_controller(options)
        end
      end
    end
  end
end

