module Ctc
  module Questions
    class SpouseReviewController < QuestionsController
      include AuthenticatedCtcClientConcern
      include AnonymousIntakeConcern

      layout "intake"

      def self.show?(intake)
        intake.client.tax_returns.last.filing_status_married_filing_jointly?
      end

      private

      def form_class
        NullForm
      end

      def illustration_path; end

    end
  end
end