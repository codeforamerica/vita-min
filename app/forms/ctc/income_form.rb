module Ctc
  class IncomeForm < QuestionsForm
    set_attributes_for :intake, :had_reportable_income

    def save
      return true if !@intake.persisted? && had_reportable_income == "yes"

      @intake.assign_attributes(attributes_for(:intake))
      @intake.save
    end
  end
end