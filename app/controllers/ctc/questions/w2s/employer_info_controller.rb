module Ctc
  module Questions
    module W2s
      class EmployerInfoController < BaseW2Controller
        # def self.show?(intake)
        #   Flipper.enabled?(:eitc) &&
        #     intake.exceeded_investment_income_limit_no? &&
        #     intake.primary_birth_date > 24.years.ago &&
        #     intake.dependents.none?(&:qualifying_eitc?)
        # end

        private

        def illustration_path
          "documents.svg"
        end
      end
    end
  end
end
