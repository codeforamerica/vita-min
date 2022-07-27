module Ctc
  class InvestmentIncomeForm < QuestionsForm
    set_attributes_for :intake, :exceeded_investment_income_limit

    def save
      @intake.update(attributes_for(:intake))
    end
  end
end