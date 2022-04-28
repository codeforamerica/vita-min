module Ctc
  module Questions
    class UseGyrController < QuestionsController
      include PreviousPathIsBackConcern

      layout "intake"

      def next_path
        nil
      end

      private

      def form_class
        NullForm
      end

      def illustration_path
        "warning-triangle-yellow.svg"
      end
    end
  end
end