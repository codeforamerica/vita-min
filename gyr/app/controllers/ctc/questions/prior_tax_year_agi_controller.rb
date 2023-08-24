module Ctc
  module Questions
    class PriorTaxYearAgiController < QuestionsController
      include Ctc::ResetToStartIfIntakeNotPersistedConcern

      layout "intake"

      def self.show?(intake)
        intake.filed_prior_tax_year_filed_full?
      end

      private

      def illustration_path
        "hand-holding-check.svg"
      end
    end
  end
end
