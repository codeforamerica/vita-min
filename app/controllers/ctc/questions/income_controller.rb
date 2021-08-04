module Ctc
  module Questions
    class IncomeController < QuestionsController
      include AnonymousIntakeConcern
      layout "yes_no_question"

      def current_intake
        Intake::CtcIntake.new
      end

      private

      def method_name
        "had_reportable_income"
      end

      def illustration_path
        "hand-holding-check.svg"
      end

      def next_path
        @form.had_reportable_income? ? questions_use_gyr_path : super
      end
    end
  end
end
