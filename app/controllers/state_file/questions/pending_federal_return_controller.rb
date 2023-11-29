module StateFile
  module Questions
    class PendingFederalReturnController < QuestionsController
      def self.show?(_intake)
        false
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
