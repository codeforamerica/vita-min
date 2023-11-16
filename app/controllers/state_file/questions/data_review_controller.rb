module StateFile
  module Questions
    class DataReviewController < QuestionsController
      private

      def form_class
        NullForm
      end

      def prev_path
        nil
      end
    end
  end
end
