module StateFile
  module Questions
    class SubmitReturnController < QuestionsController
      layout "state_file/question"

      private

      def next_path
        root_path
      end

      def illustration_path
        "welcome.svg"
      end

      def after_update_success
        session[:intake_id] = nil
        flash[:notice] = "Submitted efile submission"
      end
    end
  end
end
