module StateFile
  module Questions
    class NjCollegeDependentsExemptionController < QuestionsController
      include ReturnToReviewConcern

      def self.show?(intake)
        intake.dependents.count(&:under_22?).positive?
      end

      def form_params
        params
          .require(:state_file_nj_college_dependents_exemption_form)
          .permit(
              [{ dependents_attributes: [
                :id, 
                :nj_dependent_attends_accredited_program, 
                :nj_dependent_enrolled_full_time, 
                :nj_dependent_five_months_in_college, 
                :nj_filer_pays_tuition_for_dependent
              ] }])
      end
    end
  end
end 