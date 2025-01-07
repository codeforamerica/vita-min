module StateFile
  module Questions
    class NjDependentsHealthInsuranceController < QuestionsController

      before_action -> { @filing_year = Rails.configuration.statefile_current_tax_year }

      def self.show?(intake)
        return false unless intake.dependents.any?
        intake.has_health_insurance_requirement_exception? || intake.eligibility_all_members_health_insurance_no?
      end

      def form_params
        params
          .fetch(:state_file_nj_dependents_health_insurance_form, {})
          .permit([
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