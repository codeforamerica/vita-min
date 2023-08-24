class WidowedYearForm < QuestionsForm
  set_attributes_for :intake, :widowed_year

  def save
    @intake.update(attributes_for(:intake))
  end
end