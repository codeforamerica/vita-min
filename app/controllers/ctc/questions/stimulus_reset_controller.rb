module Ctc
  module Questions
    class StimulusResetController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"

      def self.show?(intake)
        false
      end

      # there is no edit page for this endpoint
      def edit
        redirect_back(fallback_location: prev_path)
      end

      private

      def illustration_path;end
    end
  end
end
