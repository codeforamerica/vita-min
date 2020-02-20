class HadDisabilityForm < QuestionsForm
  set_attributes_for :intake, :had_disability

  def save
    @intake.update(attributes_for(:intake))
  end
end