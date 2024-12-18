module StateFile
  module Questions
    class NjHouseholdRentOwnController < QuestionsController
      include ReturnToReviewConcern

      def next_path
        options = {}
        options[:return_to_review] = params[:return_to_review] if params[:return_to_review].present?

        if Efile::Nj::NjPropertyTaxEligibility.ineligible?(current_intake)
          return super # skip remaining property tax questions and go to whichever is next by default
        end
        
        case current_intake.household_rent_own
        when 'rent'
          NjTenantEligibilityController.to_path_helper(options)
        when 'own'
          NjHomeownerEligibilityController.to_path_helper(options)
        when 'both'
          NjIneligiblePropertyTaxController.to_path_helper(options)
        when 'neither'
          NjIneligiblePropertyTaxController.to_path_helper(options)
        else
          super
        end
      end
    end
  end
end

