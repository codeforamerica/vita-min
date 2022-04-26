module Ctc
  module Questions
    class SpouseDriversLicenseController < QuestionsController
      include AuthenticatedCtcClientConcern
      include AnonymousIntakeConcern

      layout "intake"

      def show?(intake)
        intake.client.tax_returns.last.filing_status_married_filing_jointly?
      end

      def illustration_path
        "ids.svg"
      end
    end
  end
end
