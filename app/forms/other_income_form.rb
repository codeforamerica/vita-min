class OtherIncomeForm < QuestionsForm
  set_attributes_for :intake, :had_other_income

  def save
    @intake.update(attributes_for(:intake))
  end
end