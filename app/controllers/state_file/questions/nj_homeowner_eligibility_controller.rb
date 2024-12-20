module StateFile
  module Questions
    class NjHomeownerEligibilityController < QuestionsController
      include ReturnToReviewConcern

      def next_path
        options = {}
        options[:return_to_review] = params[:return_to_review] if params[:return_to_review].present?

        if StateFile::NjHomeownerEligibilityHelper.determine_eligibility(current_intake) == StateFile::NjHomeownerEligibilityHelper::INELIGIBLE
          options[:on_home_or_rental] = :home
          NjIneligiblePropertyTaxController.to_path_helper(options)
        elsif Efile::Nj::NjPropertyTaxEligibility.possibly_eligible_for_credit?(current_intake)
          StateFile::NjPropertyTaxFlowOffRamp.next_controller(options)
        elsif StateFile::NjHomeownerEligibilityHelper.determine_eligibility(current_intake) == StateFile::NjHomeownerEligibilityHelper::WORKSHEET
          NjHomeownerPropertyTaxWorksheetController.to_path_helper(options)
        else
          NjHomeownerPropertyTaxController.to_path_helper(options)
        end
      end

      def prev_path
        options = {}
        options[:return_to_review] = params[:return_to_review] if params[:return_to_review].present?
        NjHouseholdRentOwnController.to_path_helper(options)
      end
    end
  end
end