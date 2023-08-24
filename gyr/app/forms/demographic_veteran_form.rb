class DemographicVeteranForm < QuestionsForm
  set_attributes_for :intake, :demographic_veteran
  validates_presence_of :demographic_veteran

  def save
    @intake.update(attributes_for(:intake))
  end
end
