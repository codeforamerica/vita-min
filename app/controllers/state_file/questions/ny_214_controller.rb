module StateFile
  module Questions
    class Ny214Controller < QuestionsController
      layout "state_file/question"

      private

      def illustration_path
        "mortgage-interest.svg"
      end
    end
  end
end
