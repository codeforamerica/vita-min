module StateFile
  module Questions
    class PendingFederalReturnController < QuestionsController
      skip_before_action :set_current_step

      def prev_path
        nil
      end
    end
  end
end
