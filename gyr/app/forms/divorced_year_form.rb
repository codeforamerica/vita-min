class DivorcedYearForm < QuestionsForm
  set_attributes_for :intake, :divorced_year

  def save
    @intake.update(attributes_for(:intake))
  end
end