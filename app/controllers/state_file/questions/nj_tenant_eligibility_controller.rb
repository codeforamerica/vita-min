module StateFile
  module Questions
    class NjTenantEligibilityController < QuestionsController
      include ReturnToReviewConcern

      def self.show?(intake)
        intake.household_rent_own_rent? && !Efile::Nj::NjPropertyTaxEligibility.ineligible?(intake)
      end

      def next_path
        options = {}
        options[:return_to_review] = params[:return_to_review] if params[:return_to_review].present?
        
        case StateFile::NjTenantEligibilityHelper.determine_eligibility(current_intake)
        when StateFile::NjTenantEligibilityHelper::INELIGIBLE
          NjIneligiblePropertyTaxController.to_path_helper(options)
        when StateFile::NjTenantEligibilityHelper::UNSUPPORTED
          NjUnsupportedPropertyTaxController.to_path_helper(options)
        else
          if Efile::Nj::NjPropertyTaxEligibility.possibly_eligible_for_credit?(current_intake)
            super # skip "rent paid" question and go to whichever is next by default
          else
            NjTenantRentPaidController.to_path_helper(options)
          end
        end
      end
    end
  end
end