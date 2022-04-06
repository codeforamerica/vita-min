module Ctc
  module Questions
    class IncomeController < QuestionsController
      include AnonymousIntakeConcern
      include FirstPageOfCtcIntakeConcern

      layout "yes_no_question"

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

      def tracking_data
        @form.attributes_for(:misc)
      end
    end
  end
end
