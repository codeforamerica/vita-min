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
        # if current_intake.dependents.count > 0 # If the client has already added dependents, take them to the confirmation page to add more or continue.
        #   questions_confirm_dependents_path
        # elsif current_intake.had_dependents_no?
        #   super
        # else
          Ctc::Questions::W2s::EmployeeInfoController.to_path_helper(id: 12345)
        # end
      end

      private

      def illustration_path; end
    end
  end
end
