class InterestIncomeForm < QuestionsForm
  set_attributes_for :intake, :had_interest_income

  def save
    @intake.update(attributes_for(:intake))
  end
end