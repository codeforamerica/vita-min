module StateFile
  module Questions
    class IdGroceryCreditController < QuestionsController
      include ReturnToReviewConcern

      def self.show?(intake)
        !intake.direct_file_data.claimed_as_dependent?
      end

      private

      def form_params
        params
          .require(:state_file_id_grocery_credit_form)
          .permit(
            form_class.attribute_names +
              [{ dependents_attributes: [:id, :id_has_grocery_credit_ineligible_months, :id_months_ineligible_for_grocery_credit] }])
      end
    end
  end
end
