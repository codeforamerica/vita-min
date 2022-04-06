module Ctc
  class IncomeForm < QuestionsForm
    include InitialCtcFormAttributes
    set_attributes_for :misc, :had_reportable_income

    def had_reportable_income?
      had_reportable_income == "yes"
    end
  end
end
