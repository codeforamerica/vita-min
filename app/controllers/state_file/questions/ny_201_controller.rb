module StateFile
  module Questions
    class Ny201Controller < QuestionsController
      include ReturnToReviewConcern

      private

      def illustration_path
        "wages.svg"
      end
    end
  end
end
