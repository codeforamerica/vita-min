class DemographicSpouseEthnicityForm < QuestionsForm
  set_attributes_for :intake, :demographic_spouse_ethnicity

  def save
    @intake.update(attributes_for(:intake))
  end
end