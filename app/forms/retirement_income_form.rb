class RetirementIncomeForm < QuestionsForm
  set_attributes_for :intake, :had_retirement_income

  def save
    @intake.update(attributes_for(:intake))
  end
end