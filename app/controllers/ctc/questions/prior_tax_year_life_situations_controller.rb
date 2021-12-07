module Ctc
  module Questions
    class PriorTaxYearLifeSituationsController < QuestionsController

      layout "intake"

      def self.show?(intake)
        intake.filed_prior_tax_year_filed_full? || intake.filed_prior_tax_year_filed_non_filer?
      end

      private

      def form_class
        NullForm
      end

      def illustration_path; end
    end
  end
end