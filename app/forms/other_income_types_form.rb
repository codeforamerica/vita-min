class OtherIncomeTypesForm < QuestionsForm
  set_attributes_for :intake, :other_income_types

  def save
    @intake.update(attributes_for(:intake))
  end
end