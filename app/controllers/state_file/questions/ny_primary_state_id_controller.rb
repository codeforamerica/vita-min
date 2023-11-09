module StateFile
  module Questions
    class NyPrimaryStateIdController < QuestionsController
      def edit
        @person_type = :primary
        super
      end

      private

      def edit_template
        "state_file/questions/ny_state_id/edit"
      end
    end
  end
end
