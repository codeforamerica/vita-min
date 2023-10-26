module StateFile
  module Questions
    class LoginController < QuestionsController
      private

      def form_class
        NullForm
      end
    end
  end
end
