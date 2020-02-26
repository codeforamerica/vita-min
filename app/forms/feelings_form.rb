class FeelingsForm < QuestionsForm
  set_attributes_for :intake, :feeling_about_taxes

  def save
    @intake.update(attributes_for(:intake))
  end
end