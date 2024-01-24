module StateFile
  module Questions
    class CodeVerifiedController < QuestionsController
      private

      def form_class
        NullForm
      end
    end
  end
end