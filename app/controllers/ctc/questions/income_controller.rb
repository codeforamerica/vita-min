module Ctc
  module Questions
    class IncomeController < QuestionsController
      include AnonymousIntakeConcern

      layout "intake"

      private

      def form_class
        NullForm
      end

      def illustration_path
        "hand-holding-check.svg"
      end

      def tracking_data
        # WIP, ask if still need question_answered event
        {
          income_qualifies: ""
        }
      end
    end
  end
end
