module Ctc
  module Questions
    class IncomeController < QuestionsController
      include AnonymousIntakeConcern
      include FirstQuestionConcern

      layout "yes_no_question"

      private

      def method_name
        "had_reportable_income"
      end

      def illustration_path
        "hand-holding-check.svg"
      end

      def next_path
        @form.had_reportable_income == "yes" ? questions_placeholder_question_path : super
      end
    end
  end
end