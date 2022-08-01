module Ctc
  module Questions
    class EitcExceptionsController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"

      private

      def illustration_path; end
    end
  end
end