module StateFile
  module Questions
    class IdGroceryCreditController < QuestionsController
      def self.show?(intake)
        !intake.direct_file_data.claimed_as_dependent?
      end

      private

      def next_path
        prev = super
        if params[:return_to_review].present?
          uri = URI.parse(prev)
          new_params = URI.decode_www_form(uri.query || '') << ['return_to_review', params[:return_to_review]]
          uri.query = URI.encode_www_form(new_params)
          prev = uri.to_s
        end
        prev
      end

      def form_params
        params
          .fetch(:state_file_id_grocery_credit_form, {})
          .permit(
            form_class.attribute_names +
              [{ dependents_attributes: [:id, :id_has_grocery_credit_ineligible_months, :id_months_ineligible_for_grocery_credit] }])
      end
    end
  end
end
