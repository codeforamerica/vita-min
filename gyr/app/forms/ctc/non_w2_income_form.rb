module Ctc
  class NonW2IncomeForm < QuestionsForm
    set_attributes_for :intake, :had_disqualifying_non_w2_income

    def save
      @intake.update(attributes_for(:intake))
    end
  end
end
