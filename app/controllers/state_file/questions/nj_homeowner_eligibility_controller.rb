module StateFile
  module Questions
    class NjHomeownerEligibilityController < QuestionsController
      include ReturnToReviewConcern

      before_action -> { @filing_year = Rails.configuration.statefile_current_tax_year }

      def self.show?(intake)
        intake.household_rent_own_own? &&
        Efile::Nj::NjPropertyTaxEligibility.determine_eligibility(intake) != Efile::Nj::NjPropertyTaxEligibility::INELIGIBLE
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
          if Efile::Nj::NjPropertyTaxEligibility.determine_eligibility(current_intake) == Efile::Nj::NjPropertyTaxEligibility::POSSIBLY_ELIGIBLE_FOR_CREDIT
            super # skip "property taxes paid" question and go to whichever comes next by default
          else
            NjHomeownerPropertyTaxController.to_path_helper(options)
          end
        end
      end
    end
  end
end