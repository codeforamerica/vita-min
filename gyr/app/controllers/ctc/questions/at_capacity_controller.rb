module Ctc
  module Questions
    class AtCapacityController < QuestionsController
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
        "capacity.svg"
      end

    end
  end
end