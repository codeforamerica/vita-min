module Ctc
  module Questions
    class SpousePriorTaxYearAgiController < QuestionsController
      include Ctc::ResetToStartIfIntakeNotPersistedConcern

      layout "intake"

      def self.show?(intake)
        intake.spouse_filed_prior_tax_year_filed_full_separate?
      end

      private

      def illustration_path
        "hand-holding-check.svg"
      end
    end
  end
end
