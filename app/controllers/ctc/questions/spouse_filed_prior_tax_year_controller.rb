module Ctc
  module Questions
    class SpouseFiledPriorTaxYearController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"

      def self.show?(intake)
        intake.filing_jointly?
      end

      private

      def illustration_path
        "hand-holding-check.svg"
      end
    end
  end
end
