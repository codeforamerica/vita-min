module Ctc
  module Questions
    class W2sController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"

      # def self.show?(intake)
      #   Flipper.enabled?(:eitc) &&
      #     intake.exceeded_investment_income_limit_no? &&
      #     intake.primary_birth_date > 24.years.ago &&
      #     intake.dependents.none?(&:qualifying_eitc?)
      # end

      def self.form_class
        NullForm
      end

      def next_path
        form_navigation.next(Ctc::Questions::ConfirmW2sController).to_path_helper
      end

      private

      def illustration_path; end
    end
  end
end
