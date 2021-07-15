module Ctc
  class IncomeForm < QuestionsForm
    set_attributes_for :intake, :had_reportable_income

    def save; end

    def had_reportable_income?
      had_reportable_income == "yes"
    end
  end
end