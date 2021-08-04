module Ctc
  module Questions
    class PrimaryActiveArmedForcesController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "yes_no_question"

      private

      def illustration_path; end
    end
  end
end