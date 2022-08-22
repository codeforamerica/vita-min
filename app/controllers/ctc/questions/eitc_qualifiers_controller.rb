module Ctc
  module Questions
    class EitcQualifiersController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"

      def self.show?(intake)
        Flipper.enabled?(:eitc) &&
          intake.exceeded_investment_income_limit_no? &&
          intake.primary_birth_date > 24.years.ago &&
          intake.dependents.none?(&:qualifying_eitc?)
      end

      private

      def illustration_path; end
    end
  end
end