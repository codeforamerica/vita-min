class GamblingIncomeForm < QuestionsForm
  set_attributes_for :intake, :had_gambling_income

  def save
    @intake.update(attributes_for(:intake))
  end
end