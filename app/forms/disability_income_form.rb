class DisabilityIncomeForm < QuestionsForm
  set_attributes_for :intake, :had_disability_income

  def save
    @intake.update(attributes_for(:intake))
  end
end