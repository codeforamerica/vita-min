module Ctc
  module Questions
    class SpouseReviewController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"

      def self.show?(intake)
        intake.filing_joint?
      end

      private

      def form_class
        NullForm
      end

      def illustration_path; end

    end
  end
end