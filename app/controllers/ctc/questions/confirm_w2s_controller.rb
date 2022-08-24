module Ctc
  module Questions
    class ConfirmW2sController < QuestionsController
      include AuthenticatedCtcClientConcern

      layout "intake"

      # # def self.show?(intake)
      # #   Flipper.enabled?(:eitc) &&
      # #     intake.exceeded_investment_income_limit_no? &&
      # #     intake.primary_birth_date > 24.years.ago &&
      # #     intake.dependents.none?(&:qualifying_eitc?)
      # # end
      #
      def edit
        render 'ctc/questions/w2s/edit'
        # super
      end

      def self.form_class
        NullForm
      end

      private

      def illustration_path; end
    end
  end
end
