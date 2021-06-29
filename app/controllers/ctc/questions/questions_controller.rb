module Ctc
  module Questions
    class QuestionsController < ::Questions::QuestionsController
      helper_method :wrapping_layout

      private

      def wrapping_layout
        "ctc"
      end

      def question_navigator
        CtcQuestionNavigation
      end

      def parent_class
        Intake::CtcIntake
      end

      class << self
        def form_key
          "ctc/" + controller_name + "_form"
        end

        def path_helper_string
          [
            "questions",
            controller_name,
            "path"
          ].join("_")
        end
      end
    end
  end
end