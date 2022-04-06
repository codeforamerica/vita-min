module Ctc
  class IncomeForm < QuestionsForm
    set_attributes_for :misc, :income_qualifies

    def save; end

    def income_qualifies?
      income_qualifies == "yes"
    end
  end
end
