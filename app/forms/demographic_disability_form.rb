class DemographicDisabilityForm < QuestionsForm
  set_attributes_for :intake, :demographic_disability
  validates_presence_of :demographic_disability, message: "Please answer or click \"Skip question\""

  def save
    @intake.update(attributes_for(:intake))
  end
end