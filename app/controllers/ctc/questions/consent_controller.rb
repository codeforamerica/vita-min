module Ctc
  module Questions
    class ConsentController < QuestionsController
      include FirstQuestionConcern
      include AnonymousIntakeConcern
      layout "intake"

      private

      def illustration_path; end
    end
  end
end