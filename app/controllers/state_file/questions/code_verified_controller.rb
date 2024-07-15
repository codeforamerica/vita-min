module StateFile
  module Questions
    class CodeVerifiedController < AuthenticatedQuestionsController
      private

      def form_class
        NullForm
      end
    end
  end
end