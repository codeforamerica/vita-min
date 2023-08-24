class SeparatedForm < QuestionsForm
  set_attributes_for :intake, :separated

  def save
    @intake.update(attributes_for(:intake))
  end
end