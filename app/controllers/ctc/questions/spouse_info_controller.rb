module Ctc
  module Questions
    class SpouseInfoController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"

      def self.show?(intake, _dependent)
        intake.client.tax_returns.last.filing_status_married_filing_jointly?
      end

      private

      def next_path
        return questions_use_gyr_path if @form.intake.spouse_tin_type_none?

        super
      end

      def illustration_path; end

    end
  end
end