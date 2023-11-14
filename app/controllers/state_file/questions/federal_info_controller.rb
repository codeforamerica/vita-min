module StateFile
  module Questions
    class FederalInfoController < QuestionsController
      layout "state_file/question"

      private

      def illustration_path
        nil
      end
    end
  end
end
