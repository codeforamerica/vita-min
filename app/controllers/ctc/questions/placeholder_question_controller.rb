module Ctc
  module Questions
    class PlaceholderQuestionController < QuestionsController
      include AnonymousIntakeConcern

      private

      def illustration_path; end

      def form_class
        NullForm
      end
    end
  end
end