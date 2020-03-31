class BacktaxesForm < QuestionsForm
  set_attributes_for :intake, :needs_help_2016, :needs_help_2017, :needs_help_2018, :needs_help_2019

  def save
    @intake.update(attributes_for(:intake))
  end
end