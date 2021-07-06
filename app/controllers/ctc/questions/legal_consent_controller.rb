module Ctc
  module Questions
    class LegalConsentController < QuestionsController
      include AnonymousIntakeConcern

      layout "intake"

      def update
        super
      end

      private

      def prev_path
        questions_placeholder_question_path # TODO: replace with verify identity path
      end

      def next_path
        questions_placeholder_question_path # replace with 2020 tax return question
      end
    end
  end
end