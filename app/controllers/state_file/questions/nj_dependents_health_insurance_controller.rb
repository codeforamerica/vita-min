module StateFile
  module Questions
    class NjDependentsHealthInsuranceController < QuestionsController

      def self.show?(intake)
        intake.dependents.any?
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