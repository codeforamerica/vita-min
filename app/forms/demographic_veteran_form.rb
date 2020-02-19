class DemographicVeteranForm < QuestionsForm
  set_attributes_for :intake, :demographic_veteran
  validates_presence_of :demographic_veteran, message: "Please answer or click \"Skip question\""

  def save
    @intake.update(attributes_for(:intake))
  end
end