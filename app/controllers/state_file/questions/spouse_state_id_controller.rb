module StateFile
  module Questions
    class SpouseStateIdController < QuestionsController
      include ReturnToReviewConcern

      def self.show?(intake)
        intake.filing_status_mfj?
      end

      def edit
        super
        render state_specific_view
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
          render state_specific_view
        end
      end

      private

      def state_specific_view
        "state_file/questions/#{current_state_code}_spouse_state_id/_#{current_state_code}_spouse"
      end
    end
  end
end
