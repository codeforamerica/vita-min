module StateFile
  module Questions
    class NjEligibilityHealthInsuranceController < QuestionsController
      include EligibilityOffboardingConcern

      before_action -> { @filing_year = Rails.configuration.statefile_current_tax_year }

      def self.show?(intake)
        !intake.has_health_insurance_requirement_exception?
      end

      def form_params
        params
          .fetch(:state_file_nj_eligibility_health_insurance_form, {})
          .permit([:eligibility_all_members_health_insurance])
      end

    end
  end
end