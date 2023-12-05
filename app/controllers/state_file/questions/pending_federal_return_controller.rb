module StateFile
  module Questions
    class PendingFederalReturnController < QuestionsController
      def prev_path
        nil
      end

      private

      # edit page has no us_state in the params so default implementation of current_intake doesn't work
      def current_intake
        GlobalID.find(session[:state_file_intake])
      end
    end
  end
end
