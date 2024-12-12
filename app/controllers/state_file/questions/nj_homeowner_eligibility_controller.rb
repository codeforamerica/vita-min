module StateFile
  module Questions
    class NjHomeownerEligibilityController < QuestionsController
      include ReturnToReviewConcern

      # def self.show?(intake)
      #   (intake.household_rent_own_own? || intake.household_rent_own_both?) &&
      #     !Efile::Nj::NjPropertyTaxEligibility.ineligible?(intake)
      # end

      def next_path
        options = {}
        options[:return_to_review] = params[:return_to_review] if params[:return_to_review].present?

        if StateFile::NjHomeownerEligibilityHelper.determine_eligibility(current_intake) == StateFile::NjHomeownerEligibilityHelper::INELIGIBLE
          NjIneligiblePropertyTaxController.to_path_helper(options)
        elsif Efile::Nj::NjPropertyTaxEligibility.possibly_eligible_for_credit?(current_intake)
          super # skip "property taxes paid" question and go to whichever comes next by default
        elsif StateFile::NjHomeownerEligibilityHelper.determine_eligibility(current_intake) == StateFile::NjHomeownerEligibilityHelper::WORKSHEET
          NjHomeownerPropertyTaxWorksheetController.to_path_helper(options)
        else
          NjHomeownerPropertyTaxController.to_path_helper(options)
        end
      end
    end
  end
end