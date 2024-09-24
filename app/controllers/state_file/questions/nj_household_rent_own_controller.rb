module StateFile
  module Questions
    class NjHouseholdRentOwnController < QuestionsController
      include ReturnToReviewConcern
      def edit
        @filing_year = Rails.configuration.statefile_current_tax_year
        super
      end

      def next_path
        options = {}
        options[:return_to_review] = params[:return_to_review] if params[:return_to_review].present?
        case current_intake.household_rent_own
        when 'rent'
          NjRenterRentPaidController.to_path_helper(options)
        when 'own'
          NjHomeownerPropertyTaxController.to_path_helper(options)
        else
          super
        end
      end
    end
  end
end

