class WorkSituationsForm < QuestionsForm
  set_attributes_for :intake, :had_wages, :had_self_employment_income, :had_tips, :had_unemployment_income

  def save
    @intake.update(attributes_for(:intake))
  end
end