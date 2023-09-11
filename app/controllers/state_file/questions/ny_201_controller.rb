module StateFile
  module Questions
    class Ny201Controller < QuestionsController
      layout "state_file/question"

      private

      def illustration_path
        "wages.svg"
      end
    end
  end
end
