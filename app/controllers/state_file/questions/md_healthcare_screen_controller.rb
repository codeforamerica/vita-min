module StateFile
  module Questions
    class MdHealthcareScreenController < QuestionsController
      include ReturnToReviewConcern

      def form_params
        params
          .require(:state_file_md_healthcare_screen_form)
          .permit(
            form_class.attribute_names +
              [{ dependents_attributes: [:id, :md_did_not_have_health_insurance] }])
      end
    end
  end
end
