class DivorcedForm < QuestionsForm
  set_attributes_for :intake, :divorced

  def save
    @intake.update(attributes_for(:intake))
  end
end