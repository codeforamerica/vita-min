module StateFile
  module Questions
    class DataReviewController < QuestionsController
      def edit
      end

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