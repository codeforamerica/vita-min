module Ctc
  module Questions
    class UseGyrController < QuestionsController
      include AnonymousIntakeConcern
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
        "hand-holding-check.svg"
      end

    end
  end
end