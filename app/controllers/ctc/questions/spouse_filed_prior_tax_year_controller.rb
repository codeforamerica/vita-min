module Ctc
  module Questions
    class SpouseFiledPriorTaxYearController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"

      def self.show?(intake)
        intake.client.tax_returns.last.filing_status_married_filing_jointly?
      end

      private

      def illustration_path; end

    end
  end
end