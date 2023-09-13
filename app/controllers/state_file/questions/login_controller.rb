module StateFile
  module Questions
    class LoginController < QuestionsController
      layout "state_file/question"

      private

      def form_class
        NullForm
      end

      def illustration_path; end
    end
  end
end
