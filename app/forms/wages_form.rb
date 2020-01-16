class WagesForm < QuestionsForm
  set_attributes_for :intake, :had_wages

  def save
    @intake.update(attributes_for(:intake))
  end
end