module Ctc
  module Questions
    class Filed2020Controller < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "yes_no_question"

      private

      def method_name
        "filed_2020"
      end

      def illustration_path
        "hand-holding-check.svg"
      end
    end
  end
end