module StateFile
  module Questions
    class NjHomeownerEligibilityController < QuestionsController
      include ReturnToReviewConcern

      def self.show?(intake)
        intake.household_rent_own_own? && !Efile::Nj::NjPropertyTaxEligibility.ineligible?(intake)
      end

      def next_path
        options = {}
        options[:return_to_review] = params[:return_to_review] if params[:return_to_review].present?

        case StateFile::NjHomeownerEligibilityHelper.determine_eligibility(current_intake)
        when StateFile::NjHomeownerEligibilityHelper::INELIGIBLE
          NjIneligiblePropertyTaxController.to_path_helper(options)
        when StateFile::NjHomeownerEligibilityHelper::UNSUPPORTED
          NjUnsupportedPropertyTaxController.to_path_helper(options)
        else
          if Efile::Nj::NjPropertyTaxEligibility.possibly_eligible_for_credit?(current_intake)
            super # skip "property taxes paid" question and go to whichever comes next by default
          else
            NjHomeownerPropertyTaxController.to_path_helper(options)
          end
        end
      end
    end
  end
end