module Questions
  class OtherIncomeTypesController < AuthenticatedIntakeController
    layout "intake"

    def self.show?(intake)
      intake.had_other_income_yes?
    end

    def tracking_data
      {}
    end

    def illustration_path
      "other-income.svg"
    end
  end
end