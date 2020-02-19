class DemographicDisabilityForm < QuestionsForm
  set_attributes_for :intake, :demographic_disability

  def save
    @intake.update(attributes_for(:intake))
  end
end