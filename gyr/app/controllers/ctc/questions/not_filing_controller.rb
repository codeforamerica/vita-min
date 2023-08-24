module Ctc
  module Questions
    class NotFilingController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"

      private

      def illustration_path
        "not-filing.svg"
      end

      def form_class
        NullForm
      end
    end
  end
end
