class UnemploymentIncomeForm < QuestionsForm
  set_attributes_for :intake, :had_unemployment_income

  def save
    @intake.update(attributes_for(:intake))
  end
end