module StateFile
  module Questions
    class LandingPageController < QuestionsController
      layout "state_file/question"

      private

      def illustration_path
        "welcome.svg"
      end
    end
  end
end
