module StateFile
  module Questions
    class IdDisabilityController < QuestionsController

      def self.show?(intake)
        intake.show_disability_question?
      end

      private

      def form_params
        params.fetch(:state_file_id_disability_form, {}).permit(:mfj_disability, :primary_disabled, :spouse_disabled)
      end
    end
  end
end
