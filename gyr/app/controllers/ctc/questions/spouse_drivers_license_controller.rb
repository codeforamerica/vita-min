module Ctc
  module Questions
    class SpouseDriversLicenseController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"

      def self.show?(intake)
        intake.filing_jointly?
      end

      def illustration_path
        "ids.svg"
      end
    end
  end
end
