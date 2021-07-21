module Ctc
  module Questions
    class StimulusOwedController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"

      private

      def illustration_path; end
    end
  end
end