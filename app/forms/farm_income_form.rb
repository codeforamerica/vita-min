class FarmIncomeForm < QuestionsForm
  set_attributes_for :intake, :had_farm_income

  def save
    @intake.update(attributes_for(:intake))
  end
end