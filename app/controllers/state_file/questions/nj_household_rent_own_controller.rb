module StateFile
  module Questions
    class NjHouseholdRentOwnController < QuestionsController
      include ReturnToReviewConcern

      before_action -> { @filing_year = Rails.configuration.statefile_current_tax_year }

      def next_path
        options = {}
        options[:return_to_review] = params[:return_to_review] if params[:return_to_review].present?
        case current_intake.household_rent_own
        when 'rent'
          NjRenterRentPaidController.to_path_helper(options)
        when 'own'
          NjHomeownerEligibilityController.to_path_helper(options)
        when 'both'
          NjUnsupportedPropertyTaxController.to_path_helper(options)
        when 'neither'
          NjIneligiblePropertyTaxController.to_path_helper(options)
        else
          super
        end
      end
    end
  end
end

