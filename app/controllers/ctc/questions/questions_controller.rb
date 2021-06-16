module Ctc
  module Questions
    class QuestionsController < ::Questions::QuestionsController
      def question_navigator
        CtcQuestionNavigation
      end
    end
  end
end