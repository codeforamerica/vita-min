module Ctc
  module Questions
    class ClaimEitcController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "yes_no_question"

      def edit
        super
      end

      private

      def illustration_path
        "check.svg"
      end
    end
  end
end
