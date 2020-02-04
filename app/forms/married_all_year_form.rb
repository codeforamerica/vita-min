class MarriedAllYearForm < QuestionsForm
  set_attributes_for :intake, :married_all_year

  def save
    @intake.update(attributes_for(:intake))
  end
end