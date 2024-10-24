module StateFile
  module Questions
    class PrimaryStateIdController < QuestionsController
      include ReturnToReviewConcern

      def edit
        super
        render "state_file/questions/#{current_state_code}_primary_state_id/_#{current_state_code}_primary"
      end

      def update
        @form = initialized_update_form
        if @form.valid?
          @form.save
          after_update_success
          track_question_answer
          redirect_to(next_path)
        else
          after_update_failure
          track_validation_error
          render "state_file/questions/#{current_state_code}_primary_state_id/_#{current_state_code}_primary"
        end
      end
    end
  end
end
