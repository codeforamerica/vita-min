module StateFile
  module Questions
    class SubmitReturnController < QuestionsController
      layout "intake"

      def current_intake
        StateFileNyIntake.find_by_id(session[:intake_id]) unless session[:intake_id].nil?
      end

      private

      def next_path
        root_path
      end

      def illustration_path
        "welcome.svg"
      end

      def after_update_success
        session[:intake_id] = nil
      end
    end
  end
end
