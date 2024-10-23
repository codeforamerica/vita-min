module StateFile
  module Questions
    class PrimaryStateIdController < QuestionsController
      include ReturnToReviewConcern

      def edit
        super
        render "state_file/questions/#{current_state_code}_primary_state_id/_#{current_state_code}_primary"
      end
    end
  end
end
