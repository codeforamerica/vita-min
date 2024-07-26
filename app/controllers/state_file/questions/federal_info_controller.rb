module StateFile
  module Questions
    class FederalInfoController < QuestionsController
      before_action :redirect_on_prod

      layout "state_file/question"

      def self.show?(_intake)
        false
      end

      private

      def redirect_on_prod
        redirect_to prev_path if acts_like_production?
      end

      def form_params
        params.fetch(form_name, {}).permit(
          *form_class.attribute_names,
          form_class.nested_attribute_names
        )
      end

      def illustration_path
        nil
      end
    end
  end
end
