class SeparatedYearForm < QuestionsForm
  set_attributes_for :intake, :separated_year

  def save
    @intake.update(attributes_for(:intake))
  end
end