module StateFile
  module Questions
    class SetUpAccountController < QuestionsController
      include StartIntakeConcern

      private

      def after_update_success
        session[:state_file_intake] = current_intake.to_global_id
      end
    end
  end
end
