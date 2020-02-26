class FeelingsForm < QuestionsForm
  set_attributes_for :intake, :feeling_about_taxes, :source, :referrer

  def save
    @intake.update(attributes_for(:intake))
  end
end