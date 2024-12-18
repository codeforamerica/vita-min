module StateFile
  module Questions
    class MdHadHealthInsuranceController < QuestionsController
      def form_params
        if params[:state_file_md_had_health_insurance_form]
        params
          .fetch(:state_file_md_had_health_insurance_form, {})
          .permit(
            form_class.attribute_names +
              [{ dependents_attributes: [:id, :md_did_not_have_health_insurance] }])
        end
      end
    end
  end
end
