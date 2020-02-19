class DemographicVeteranForm < QuestionsForm
  set_attributes_for :intake, :demographic_veteran

  def save
    @intake.update(attributes_for(:intake))
  end
end