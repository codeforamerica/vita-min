module StateFile
  module Questions
    class NjHomeownerPropertyTaxWorksheetController < QuestionsController

      before_action -> { @municipality = current_intake.municipality_name }

      def prev_path
        options = {}
        options[:return_to_review] = params[:return_to_review] if params[:return_to_review].present?
        NjHouseholdRentOwnController.to_path_helper(options)
      end

      def next_path
        options = {}
        options[:return_to_review] = params[:return_to_review] if params[:return_to_review].present?

        if current_intake.household_rent_own_both?
          NjTenantEligibilityController.to_path_helper(options)
        else
          StateFile::NjPropertyTaxFlowOffRamp.next_controller(options)
        end
      end
    end
  end
end