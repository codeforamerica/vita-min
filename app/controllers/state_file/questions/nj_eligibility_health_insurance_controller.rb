module StateFile
  module Questions
    class NjEligibilityHealthInsuranceController < QuestionsController
      include EligibilityOffboardingConcern

      before_action -> { @filing_year = Rails.configuration.statefile_current_tax_year }

      def form_params
        params
          .fetch(:state_file_nj_eligibility_health_insurance_form, {})
          .permit([
                    :eligibility_all_members_health_insurance,
                    {
                      dependents_attributes: [
                        :id, 
                        :nj_did_not_have_health_insurance, 
                      ] 
                    }
                  ])
      end
    end
  end
end